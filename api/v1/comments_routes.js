const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
const { getUserData } = require("./functions/users");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);
const allowedCharactersRegex =
  /^[a-zA-Z0-9\s.,!?()\-_+=*&^%$#@[\]{}|\\/<>:;"'`]*$/;

const createComment = async (request, response) => {
  // !caution: caching in this is not the best
  // TODO: other way to caching data
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
    const userDataString = await getUserData(token);
    const user_id = JSON.parse(userDataString)["user_id"];

    // Create the comment
    if (cachingBool) {
      await redisClient.del(`comments_data:${post_id}`);

      const postStats = await redisClient.hGet(
        "post_stats_data",
        `post:stats:${post_id}`
      );

      if (postStats) {
        const postStatsObject = JSON.parse(postStats);
        postStatsObject["total_comments"] += 1;

        await redisClient.hSet(
          "post_stats_data",
          `post:stats:${post_id}`,
          JSON.stringify(postStatsObject)
        );
      }
    }

    // TODO: implement caching when cahing bool is true
    // await pool.query(
    //   "UPDATE posts_stats SET total_comments = total_comments + 1 WHERE post_id = $1",
    //   [post_id]
    // );

    await pool.query(
      "INSERT INTO posts_comments_link (post_id, user_id, comment_content) VALUES ($1, $2, $3) RETURNING comment_id",
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
  var offset = parseInt(request.query.offset);
  var post_id = parseInt(request.body.post_id);

  if (!offset) {
    offset = 0;
  }

  if (offset % 10 !== 0) {
    return response
      .status(400)
      .json({ error: "offset should be 10 multiple only" });
  }

  if (!post_id) {
    return response.status(400).json({ error: "post_id is required" });
  }

  try {
    if (cachingBool) {
      redisClient.select(0);

      const value = await redisClient.hGet(
        `comments_data:${post_id}`,
        `comments:postID-${post_id}:${offset}`
      );

      if (value) {
        // Data found in Redis, parse and send response
        return response.status(200).json(JSON.parse(value));
      }
    }
    pool.query(
      `SELECT
        posts_comments_link.comment_id,
        users.username,
        posts_comments_link.comment_content,
        posts_comments_link.created_at,
        users.avatar_url
        FROM
        posts_comments_link
        JOIN
          users ON posts_comments_link.user_id = users.user_id
        WHERE
          posts_comments_link.active = 'T' AND posts_comments_link.post_id = $1
        ORDER BY
          posts_comments_link.created_at DESC
        LIMIT 10
        OFFSET $2`,
      [post_id, offset],
      async (error, result) => {
        if (error) {
          return response.status(500).json({ error: error });
        }
        const userData = result.rows;

        if (cachingBool) {
          await redisClient.hSet(
            `comments_data:${post_id}`,
            `comments:postID-${post_id}:${offset}`,
            JSON.stringify(userData)
          );
        }
        return response.status(200).json(userData);
      }
    );
  } catch (error) {
    console.error("Database error:", error);
    response.status(400).json({ error: error.message });
  }
};

router.post("/createComment", createComment);
router.post("/getpostcomment", getPostComment);

module.exports = router;
