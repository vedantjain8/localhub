const express = require("express");
const router = express.Router();

const moment = require("moment-timezone");
const pool = require("../../db");
const redisClient = require("../../dbredis");
var validator = require("validator");
const { getAdminData } = require("../functions/users");
// const { adminLogger } = require("./functions/adminLogger");
const checkPassword = require("../functions/hash_password");

const allowedCharactersRegex = /^[a-zA-Z0-9_]*$/;

const loginAdmin = async (request, response) => {
  try {
    const { username, password } = request.body;

    if (
      !username ||
      !validator.isLength(username, { min: 4, max: 15 }) ||
      !allowedCharactersRegex.test(username)
    ) {
      return response
        .status(400)
        .json({ status: 400, response: "Enter a valid username" });
    }

    if (!password) {
      return response
        .status(400)
        .json({ status: 400, response: "Password is required" });
    }

    // Check if the user exists and get the user_id
    const userResult = await pool.query(
      "SELECT user_id, password_hash, token, user_role FROM users WHERE username = $1 AND active = true",
      [username]
    );

    const user = userResult.rows[0];

    if (!user) {
      return response
        .status(400)
        .json({ status: 400, response: "Invalid username" });
    }

    const checkPasswordBool = await checkPassword(password, user.password_hash);

    if (checkPasswordBool == true && user.role == 1) {
      const { token, user_id } = user;
      const now = moment().tz("UTC").format();

      pool.query(
        "UPDATE users SET last_login = $1 WHERE user_id = $2 ",
        [now, user_id],
        (error, result) => {
          if (error) {
            console.error(error);
            return response.status(500).json({ status: 500, response: error });
          }
          return response.status(200).json({ status: 200, response: token });
        }
      );
    } else if (checkPasswordBool == true && user.role == 0) {
      return response
        .status(401)
        .json({ status: 401, response: "User is not an admin" });
    } else {
      return response
        .status(401)
        .json({ status: 401, response: "Invalid username and password" });
    }
  } catch (error) {
    console.error(error);
    return response.status(500).json({ status: 500, response: error });
  }
};

const makeAdmin = async (request, response) => {
  const { token, new_admin_user_id, log_description } = request.body ?? null;

  if (new_admin_user_id == null) {
    return response.status(400).json({
      status: 400,
      response: "new_admin_user_id can not be null",
    });
  }

  if (!token || token == null || token == "" || token == undefined) {
    return response
      .status(400)
      .json({ status: 400, response: "token can not be null" });
  }

  const admin_data = JSON.parse((await getAdminData(token)) ?? null);

  if (admin_data == null) {
    return response
      .status(401)
      .json({ status: 401, response: "Token is not valid" });
  }

  if (admin_data["user_role"] != 1) {
    return response
      .status(401)
      .json({ status: 401, response: "User is not an admin" });
  }

  await pool.query(
    "UPDATE users SET user_role = CASE WHEN user_role = 1 THEN 0 ELSE 1 END WHERE user_id = $1 returning user_role",
    [new_admin_user_id],
    (error, result) => {
      if (error) {
        console.error(error);
        return response.status(500).json({ status: 500, response: error });
      }

      // adminLog(
      //   "admin-user-role-toggle",
      //   `User with userID: ${new_admin_user_id} has now role ${result.rows[0].user_role}`,
      //   admin_data["user_id"]
      // );

      const new_admin_token = pool.query(
        "select token from users where user_id = $1",
        [new_admin_user_id]
      );

      redisClient.del(`adminData:${new_admin_token}`);

      return response.status(200).json({
        status: 200,
        response: `User with userID: ${new_admin_user_id} has now role ${result.rows[0].user_role}`,
      });
    }
  );
};

router.post("/login", loginAdmin);
router.post("/create", makeAdmin);

module.exports = router;
