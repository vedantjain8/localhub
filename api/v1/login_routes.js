const express = require("express");
const router = express.Router();

const pool = require("../db");
var validator = require("validator");
const moment = require("moment-timezone");

// regex for alphanumeric and underscore
const allowedCharactersRegex = /^[a-zA-Z0-9_]*$/;

const loginUser = async (request, response) => {
  try {
    const { username, password_hash } = request.body;

    if (
      !username ||
      !validator.isLength(username, { min: 4, max: 15 }) ||
      !allowedCharactersRegex.test(username)
    ) {
      return response.status(400).json({ error: "Enter a valid username" });
    }

    if (!password_hash) {
      return response.status(400).json({ error: "Password is required" });
    }

    // Check if the user exists and get the user_id
    const userResult = await pool.query(
      "SELECT token, user_id FROM users WHERE username = $1 AND password_hash = $2",
      [username, password_hash]
    );

    const user = userResult.rows[0];

    if (!user || !user.token) {
      return response
        .status(400)
        .json({ error: "Invalid username or password" });
    }

    const { token, user_id } = user;
    const now = moment().tz("UTC").format();

    pool.query(
      "UPDATE users SET last_login = $1 WHERE user_id = $2 ",
      [now, user_id],
      (error, result) => {
        if (error) {
          response.status(500);
        }

        response.status(200).json({ token: token });
      }
    );
  } catch (error) {
    console.error("Error creating post error:", error);
    response.status(500).send("Error creating post");
  }
};

router.post("/login", loginUser);

module.exports = router;
