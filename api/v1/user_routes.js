const express = require("express");
const validator = require("validator");
const moment = require("moment-timezone");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
const config = require("../config/config.json");
const { getUserData } = require("./functions/users");
const { hashPassword, checkPassword } = require("./functions/hash_password");
const { generateToken, reservedKeywordsFile } = require("../tools");

const cachingBool = Boolean(config.caching);

// create new user controller function
const allowedCharactersRegex = /^[a-zA-Z0-9_]*$/;
const createUser = async (request, response) => {
  try {
    var {
      username,
      email,
      password,
      avatar_url = null,
      locality_country,
      locality_state,
      locality_city,
    } = request.body;

    // username validation
    if (
      !username ||
      !validator.isLength(username, { min: 4, max: 15 }) ||
      !allowedCharactersRegex.test(username)
    ) {
      return response
        .status(400)
        .json({ status: 400, response: "Enter a valid username" });
    }

    if (reservedKeywordsFile().includes(username.toLowerCase())) {
      return response.status(400).json({
        status: 400,
        response: "Username is a reserved keyword and cannot be used.",
      });
    }

    // Check if the username is available
    const usernameCheckResult = await pool.query(
      "SELECT * FROM users WHERE LOWER(username) = LOWER($1)",
      [username]
    );

    if (usernameCheckResult.rows.length > 0) {
      return response
        .status(400)
        .json({ status: 400, response: "Username not available" });
    }

    // email validation
    if (!email || !validator.isEmail(email)) {
      return response
        .status(400)
        .json({ status: 400, response: "Enter a valid email" });
    }

    // password validation
    if (!password || !validator.isLength(password, { min: 4, max: 255 })) {
      return response
        .status(400)
        .json({ status: 400, response: "Enter a valid password hash" });
    }

    if (!avatar_url || avatar_url == "null") {
      avatar_url = `https://api.dicebear.com/7.x/notionists/png?seed=${username}`;
    }

    const password_hash = await hashPassword(password);

    // Insert the user
    const insertUserResult = await pool.query(
      "INSERT INTO users (username, email, password_hash, avatar_url, locality_country, locality_state, locality_city, token) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING token",
      [
        username,
        email,
        password_hash,
        avatar_url,
        locality_country,
        locality_state,
        locality_city,
        generateToken(25),
      ]
    );

    response
      .status(200)
      .json({ status: 200, response: insertUserResult.rows[0].token });
  } catch (error) {
    console.error(error);
    return response.status(500).json({ status: 500, response: error });
  }
};

// delete user function
const deleteUser = async (request, response) => {
  const token = request.body.token;

  if (!token) {
    return response
      .status(400)
      .json({ status: 400, response: "token can not be null" });
  }
  const user_id = JSON.parse(await getUserData(token))["user_id"];

  if (!user_id) {
    return response
      .status(401)
      .json({ status: 401, response: "Token is not valid" });
  }

  pool.query(
    "UPDATE users SET active = 'false' WHERE userid = $1",
    [user_id],
    (error, results) => {
      if (error) {
        console.error(error);
        return response.status(500).json({ status: 500, response: error });
      }
      return response
        .status(200)
        .json({ status: 200, response: `User deleted with token: ${token}` });
    }
  );
};

const loginUser = async (request, response) => {
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
      "SELECT user_id, password_hash, token FROM users WHERE username = $1 AND active = 'true'",
      [username]
    );

    const user = userResult.rows[0];

    if (!user) {
      return response
        .status(400)
        .json({ status: 400, response: "Invalid username" });
    }

    const checkPasswordBool = await checkPassword(password, user.password_hash);

    if (checkPasswordBool) {
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

const updateUser = async (request, response) => {
  try {
    const {
      username,
      bio,
      email,
      password,
      avatar_url,
      locality_city,
      locality_state,
      locality_country,
      token,
    } = request.body;

    if (!token) {
      return response
        .status(400)
        .json({ status: 400, response: "Token is required" });
    }

    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (!user_id) {
      return response
        .status(401)
        .json({ status: 401, response: "Token is not valid" });
    }

    const userResult = await pool.query(
      "SELECT password_hash FROM users WHERE token = $1 AND active = 'true'",
      [token]
    );

    const user = userResult.rows[0];

    if (!user) {
      return response
        .status(400)
        .json({ status: 400, response: "Invalid token" });
    }

    const checkPasswordBool = await checkPassword(password, user.password_hash);

    if (checkPasswordBool) {
      const setClause = [];
      const values = [];

      if (username !== undefined) {
        if (
          !username ||
          !validator.isLength(username, { min: 4, max: 15 }) ||
          !allowedCharactersRegex.test(username)
        ) {
          return response
            .status(400)
            .json({ status: 400, response: "Enter a valid username" });
        }

        if (reservedKeywordsFile().includes(username.toLowerCase())) {
          return response.status(400).json({
            status: 400,
            response: "Username is a reserved keyword and cannot be used.",
          });
        }

        // Check if the username is available
        const usernameCheckResult = await pool.query(
          "SELECT * FROM users WHERE LOWER(username) = LOWER($1)",
          [username]
        );

        if (usernameCheckResult.rows.length > 0) {
          return response
            .status(400)
            .json({ status: 400, response: "Username not available" });
        }

        setClause.push(`username = $${values.push(username)}`);
      }

      if (bio !== undefined) {
        setClause.push(`bio = $${values.push(bio)}`);
      }

      if (email !== undefined) {
        // email validation
        if (!email || !validator.isEmail(email)) {
          return response
            .status(400)
            .json({ status: 400, response: "Enter a valid email" });
        }
        setClause.push(`email = $${values.push(email)}`);
      }

      if (avatar_url !== undefined) {
        setClause.push(`avatar_url = $${values.push(avatar_url)}`);
      }

      if (locality_city !== undefined) {
        setClause.push(`locality_city = $${values.push(locality_city)}`);
      }
      if (locality_state !== undefined) {
        setClause.push(`locality_state = $${values.push(locality_state)}`);
      }
      if (locality_country !== undefined) {
        setClause.push(`locality_country = $${values.push(locality_country)}`);
      }

      if (setClause.length === 0) {
        return response.status(400).json({
          status: 400,
          response: "No valid fields provided for update.",
        });
      }

      const updateQuery = `UPDATE users SET ${setClause.join(
        ", "
      )} WHERE token = '${token}' RETURNING user_id`;

      pool.query(updateQuery, values, async (error, results) => {
        if (error) {
          console.error(error);
          return response
            .status(500)
            .json({ status: 500, response: error.message });
        }

        if (results.rowCount === 0) {
          return response.status(404).json({
            status: 404,
            response: `No user found`,
          });
        }

        if (cachingBool) {
          await redisClient.sendCommand(["flushall"]);
        }

        response.status(200).json({
          status: 200,
          response: `User modified having user_id: ${results.rows[0].user_id}`,
        });
      });
    } else {
      return response
        .status(401)
        .json({ status: 401, response: "Unauthorised" });
    }
  } catch (error) {
    console.error(error);
    return response.status(500).json({ status: 500, response: error });
  }
};
router.post("/users", createUser);
router.post("/login", loginUser);
router.put("/users", updateUser);
router.delete("/users/delete", deleteUser);

module.exports = router;
