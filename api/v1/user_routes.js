const express = require("express");
const validator = require("validator");
const moment = require("moment-timezone");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
const config = require("../config/config.json");
const { generateToken, reservedKeywordsFile } = require("../tools");

const cachingBool = Boolean(config.caching);

// create new user controller function
const allowedCharactersRegex = /^[a-zA-Z0-9_]*$/;
const createUser = async (request, response) => {
  try {
    var {
      username,
      email,
      password_hash,
      salt,
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
      return response.status(400).json({ error: "Enter a valid username" });
    }

    if (!avatar_url || avatar_url == "null") {
      avatar_url = `https://api.dicebear.com/7.x/notionists/svg?scale=130?seed=${username}`;
    }

    if (reservedKeywordsFile().includes(username.toLowerCase())) {
      return response
        .status(400)
        .json({ error: "Username is a reserved keyword and cannot be used." });
    }

    // email validation
    if (!email || !validator.isEmail(email)) {
      return response.status(400).json({ error: "Enter a valid email" });
    }

    // password validation
    if (
      !password_hash ||
      !validator.isLength(password_hash, { min: 4, max: 255 })
    ) {
      return response
        .status(400)
        .json({ error: "Enter a valid password hash" });
    }

    // Check if the username is available
    const usernameCheckResult = await pool.query(
      "SELECT * FROM users WHERE LOWER(username) = LOWER($1)",
      [username]
    );

    if (usernameCheckResult.rows.length > 0) {
      return response.status(400).json({ error: "Username not available" });
    }

    // Insert the user
    const insertUserResult = await pool.query(
      "INSERT INTO users (username, email, password_hash, salt, avatar_url, locality_country, locality_state, locality_city, token) VALUES ($1, $2, $3, $4, $5, $6) RETURNING token",
      [
        username,
        email,
        password_hash,
        salt,
        avatar_url,
        locality_country,
        locality_state,
        locality_city,
        generateToken(25),
      ]
    );

    response.status(200).json({ token: insertUserResult.rows[0].token });
  } catch (error) {
    console.error("Error creating user:", error);
    response.status(500).json({ error: "Error creating user" });
  }
};

// delete user function
const deleteUser = (request, response) => {
  // TODO add some validtion or conformation before deleting account
  const token = request.params.token;

  if (!token) {
    return response.status(400).json({ error: "token can not be null" });
  }

  pool.query(
    "UPDATE users SET active = 'false' WHERE token = $1",
    [token],
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json({ 200: `User deleted with token: ${token}` });
    }
  );
};

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

router.post("/users", createUser);
router.post("/login", loginUser);

router.delete("/users/:token", deleteUser);

module.exports = router;
