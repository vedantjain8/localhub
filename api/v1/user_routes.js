const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
var validator = require("validator");
const { generateToken, reservedKeywordsF } = require("../tools");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);

// create new user controller function
const allowedCharactersRegex = /^[a-zA-Z0-9_]*$/;
const createUser = async (request, response) => {
  try {
    var {
      username,
      email,
      password_hash,
      avatar_url = null,
      country = "global",
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

    if (reservedKeywordsF().includes(username.toLowerCase())) {
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
      "INSERT INTO users (username, email, password_hash, avatar_url, country, token) VALUES ($1, $2, $3, $4, $5, $6) RETURNING token",
      [username, email, password_hash, avatar_url, country, generateToken(25)]
    );

    response.status(200).json({ token: insertUserResult.rows[0].token });
  } catch (error) {
    console.error("Error creating user:", error);
    response.status(500).json({ error: "Error creating user" });
  }
};

// delete user function
const deleteUser = (request, response) => {
  const token = parseInt(request.params.token);

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

const getUserPubPosts = async (request, response) => {
  var offset = parseInt(request.body.offset);
  var token = request.body.token;

  if (!offset) {
    offset = 0;
  }

  if (!token) {
    return response.status(400).json({ error: "Provide a user token" });
  }

  // Check if the user exists and get the user_id
  const userResult = await pool.query(
    "SELECT user_id FROM users WHERE token = $1",
    [token]
  );

  if (!userResult.rows.length) {
    return response.status(400).json({
      error: "Not a valid token",
    });
  }

  const user_id = userResult.rows[0].user_id;

  try {
    if (cachingBool) {
      redisClient.select(0);

      value = await redisClient.get(`postsPubBy:userID-${user_id}:${offset}`);

      if (value) {
        // Data found in Redis, parse and send response
        response.status(200).json(JSON.parse(value));
      }
    } else {
      pool.query(
        `SELECT
    posts.post_id,
    posts.post_title,
    CONCAT(SUBSTRING(posts.post_content,1,159), '...') as short_content,
    posts.image,
    posts.subreddit_id,
    posts.created_at,
    posts.total_votes,
    posts.total_comments,
    posts.total_views,
    subreddit.subreddit_name,
    subreddit.logo_url,
    EXISTS (SELECT 1 FROM user_subreddit_link WHERE user_id = $1 AND subreddit_id = subreddit.subreddit_id ) AS has_joined
  FROM
    posts
  JOIN
    subreddit ON posts.subreddit_id = subreddit.subreddit_id
  WHERE
    posts.active = 'T' 
      AND
    posts.user_id = $1
  ORDER BY
    posts.created_at DESC
  LIMIT 20
  OFFSET $2`,
        [user_id, offset],
        (error, result) => {
          if (error) {
            return response.status(500).json({ error: error });
          }
          userData = result.rows;
          if (cachingBool) {
            redisClient.setEx(
              `postsPubBy:userID-${user_id}:${offset}`,
              1800,
              JSON.stringify(userData)
            );
          }
          response.status(200).json(userData);
        }
      );
    }
  } catch (error) {
    console.error("Database error:", error);
    response.status(400).json({ error: error.message });
  }
};

router.post("/users", createUser);
router.post("/users/posts", getUserPubPosts);
router.delete("/users/:token", deleteUser);

module.exports = router;
