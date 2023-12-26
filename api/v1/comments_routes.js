const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);
const allowedCharactersRegex =
  /^[a-zA-Z0-9\s.,!?()\-_+=*&^%$#@[\]{}|\\/<>:;"'`]*$/;

const createComment = async (request, response) => {
  try {
    const { post_id, comment_content, token } = request.body;

    if (!token) {
      return response.status(400).json({ error: "token is required" });
    }
    if (!post_id) {
      return response.status(400).json({ error: "post_id is required" });
    }
    if (!comment_content) {
      return response
        .status(400)
        .json({ error: "comment_content is required" });
    }

    if (!allowedCharactersRegex.test(comment_content)) {
      return response.status(400).json({ error: "enter a valid comment" });
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

    // Create the comment
    const createPostResult = await pool.query(
      "INSERT INTO comments_link (post_id, user_id, comment_content) VALUES ($1, $2, $3) RETURNING comment_id",
      [post_id, user_id, comment_content],
      (error, result) => {
        if (error) {
          return response.status(500).json({ error: error });
        }

        return response.status(200).json(result.rows[0]);
      }
    );
  } catch (error) {
    console.error("Error creating comment error:", error);
    response.status(500).json({ error: "Error creating comment" });
  }
};

const getPostComment = async (request, response) => {
  var offset = parseInt(request.body.offset);
  var post_id = parseInt(request.body.post_id);

  if (!offset) {
    offset = 0;
  }

  if (!post_id) {
    return response.status(400).json({ error: "post_id is required" });
  }

  try {
    if (cachingBool) {
      redisClient.select(0);

      value = await redisClient.get(`comments:postID-${post_id}:${offset}`);

      if (value) {
        // Data found in Redis, parse and send response
        response.status(200).json(JSON.parse(value));
      }
    } else {
      pool.query(
        `SELECT
        comments_link.comment_id,
        users.username,
        comments_link.comment_content,
        comments_link.created_at,
        users.avatar_url
        FROM
        comments_link
  JOIN
    users ON comments_link.user_id = users.user_id
  WHERE
    comments_link.active = 'T' AND comments_link.post_id = $1
  ORDER BY
    comments_link.created_at DESC
  LIMIT 20
  OFFSET $2`,
        [post_id, offset],
        (error, result) => {
          if (error) {
            return response.status(500).json({ error: error });
          }
          userData = result.rows;

          if (cachingBool) {
            redisClient.setEx(
              `comments:postID-${post_id}:${offset}`,
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

router.post("/createComment", createComment);
router.post("/getpostcomment", getPostComment);

module.exports = router;
