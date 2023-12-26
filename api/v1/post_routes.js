const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
const { getUserId } = require("./functions/users");
var validator = require("validator");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);

// regex for alphanumeric and underscore
const allowedCharactersRegex =
  /^[a-zA-Z0-9\s.,!?()\-_+=*&^%$#@[\]{}|\\/<>:;"'`]*$/;

const createPost = async (request, response) => {
  try {
    var {
      post_title,
      post_content = "",
      subreddit_name,
      token,
      image_url,
    } = request.body;

    if (!token) {
      return response.status(400).json({ error: "Token is required" });
    }

    if (image_url == "") {
      image_url = null;
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

    // continue validatio
    if (!subreddit_name) {
      return response.status(400).json({ error: "Subreddit name is required" });
    }

    if (
      !post_title ||
      !validator.isLength(post_title, { min: 5, max: 200 }) ||
      !allowedCharactersRegex.test(post_title)
    ) {
      return response.status(400).json({ error: "Enter a valid post title" });
    }

    const user_id = userResult.rows[0].user_id;

    // Check if the subreddit name is available
    const subredditResult = await pool.query(
      "SELECT subreddit_id FROM subreddit WHERE LOWER(subreddit_name) = LOWER($1)",
      [subreddit_name]
    );

    if (!subredditResult.rows[0].subreddit_id) {
      return response
        .status(400)
        .json({ error: "Invalid subreddit name provided" });
    }

    const subreddit_id = subredditResult.rows[0].subreddit_id;

    // Create the post
    const createPostResult = await pool.query(
      "INSERT INTO posts (post_title, post_content, user_id, subreddit_id, image) VALUES ($1, $2, $3, $4, $5) RETURNING post_id",
      [post_title, post_content, user_id, subreddit_id, image_url]
    );

    response
      .status(200)
      .json({ 200: `Post added with ID: ${createPostResult.rows[0].post_id}` });

    if (cachingBool) {
      redisClient.del("posts:offset-*");
    }
  } catch (error) {
    console.error("Error creating post error:", error);
    response.status(500).json({ error: "Error creating post" });
  }
};

const getPosts = async (request, response) => {
  var offset = parseInt(request.query.offset);

  if (!offset) {
    offset = 0;
  }

  try {
    if (cachingBool) {
      redisClient.select(0);
      const value = await redisClient.get(`posts:offset-${offset}`);
      if (value) {
        response.status(200).json(JSON.parse(value)); // Data found in Redis
        return;
      }
    }

    // Data not found in Redis or caching is disabled, fetch from PostgreSQL
    const { rows: userData } = await pool.query(
      `SELECT
          posts.post_id,
          posts.post_title,
          CONCAT(SUBSTRING(posts.post_content, 1 ,159), '...') as short_content,
          posts.image,
          posts.subreddit_id,
          posts.created_at,
          posts.total_votes,
          posts.total_comments,
          posts.total_views,
          subreddit.subreddit_name,
          subreddit.logo_url
        FROM
          posts
        JOIN
          subreddit ON posts.subreddit_id = subreddit.subreddit_id
        WHERE
          posts.active = 'T'
        ORDER BY
          posts.created_at DESC
        LIMIT 20
        OFFSET $1`,
      [offset]
    );

    // Store data in Redis if caching is enabled
    if (cachingBool) {
      await redisClient.setEx(
        `posts:offset-${offset}`,
        1800,
        JSON.stringify(userData)
      );
    }

    response.status(200).json(userData);
    return;
  } catch (error) {
    console.error("Database error:", error);
    throw new Error(error.message); // Rethrow for proper error handling
  }
};

const getSubredditPosts = async (request, response) => {
  var { offset } = parseInt(request.body.offset);
  var subreddit_id = request.body.subreddit_id;

  if (!offset) {
    offset = 0;
  }

  if (!subreddit_id) {
    return response.status(400).json({ error: "subreddit_id is required" });
  }

  try {
    if (cachingBool) {
      redisClient.select(0);
      const value = await redisClient.get(
        `posts:subreddit-${subreddit_id}:${offset}`
      );
      if (value) {
        response.status(200).json(JSON.parse(value)); // Data found in Redis
        return;
      }
    }

    // Data not found in Redis or caching is disabled, fetch from PostgreSQL
    const { rows: userData } = await pool.query(
      `SELECT
      posts.post_id,
      posts.post_title,
      CONCAT(SUBSTRING(posts.post_content, 1, 159), '...') as short_content,
      posts.image,
      posts.subreddit_id,
      posts.created_at,
      posts.total_votes,
      posts.total_comments,
      posts.total_views,
      subreddit.subreddit_name,
      subreddit.logo_url
    FROM
        posts
    JOIN
        subreddit ON posts.subreddit_id = subreddit.subreddit_id
    WHERE
        posts.active = 'T'
        AND posts.subreddit_id = $1
    ORDER BY
        posts.created_at DESC
    LIMIT 20
    OFFSET $2`,
      [subreddit_id, offset]
    );

    // Store data in Redis if caching is enabled
    if (cachingBool) {
      redisClient.setEx(
        `posts:subreddit-${subreddit_id}:${offset}`,
        1800,
        JSON.stringify(userData)
      );
    }

    response.status(200).json(userData);
    return;
  } catch (error) {
    console.error("Database error:", error);
    response.status(400).json({ error: error.message });
    throw new Error(error.message); // Rethrow for proper error handling
  }
};

const getUserFeedSubredditPosts = async (request, response) => {
  var { offset } = parseInt(request.body.offset);
  var token = request.body.token;

  if (!offset) {
    offset = 0;
  }

  if (!token) {
    return response.status(400).json({ error: "Provide a user token" });
  }

  // Check if the user exists and get the user_id
  const user_id = parseInt(await getUserId(token));
  try {
    pool.query(
      `SELECT
    posts.post_id,
    posts.post_title,
    CONCAT(SUBSTRING(posts.post_content, 1, 159), '...') as short_content,
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
JOIN
    user_subreddit_link ON posts.subreddit_id = user_subreddit_link.subreddit_id
WHERE
    posts.active = 'T'
    AND user_subreddit_link.user_id = $1
ORDER BY
    posts.created_at DESC
LIMIT 20
OFFSET $2
`,
      [user_id, offset],
      (error, result) => {
        if (error) {
          return response
            .status(500)
            .json({ errorfromgetusersubredditpost: error });
        }
        userData = result.rows;
        response.status(200).json(userData);
      }
    );
    // }
  } catch (error) {
    console.error("Database error:", error);
    response.status(400).json({ error: error.message });
  }
};

const getPostById = async (request, response) => {
  const post_id = parseInt(request.params.id);

  if (!post_id) {
    return response.status(400).json({ error: "post id is required" });
  }

  try {
    if (cachingBool) {
      redisClient.select(0);

      const value = await redisClient.get(`posts:postID-${post_id}`);

      if (value) {
        // Data found in Redis, parse and send response
        response.status(200).json(JSON.parse(value));
        return;
      }
    }

    const { rows: userData } = await pool.query(
      `SELECT
        posts.post_id,
        (SELECT username from users where user_id = posts.user_id) AS post_username,
        posts.post_title,
        posts.post_content,
        posts.image,
        posts.subreddit_id,
        posts.created_at,
        posts.total_votes,
        posts.total_comments,
        posts.total_views,
        subreddit.subreddit_name,
        subreddit.logo_url
    FROM
        posts
    JOIN
        subreddit ON posts.subreddit_id = subreddit.subreddit_id
   WHERE
        posts.active = 'T' AND posts.post_id = $1`,
      [post_id]
    );

    if (cachingBool) {
      await redisClient.setEx(
        `posts:postID-${post_id}`,
        1800,
        JSON.stringify(userData)
      );
    }
    response.status(200).json(userData);
    return;
  } catch (error) {
    console.error("Database error:", error);
    response.status(400).json({ error: error.message });
  }
};

const updatePost = (request, response) => {
  const post_id = parseInt(request.params.id);
  const { post_title, post_content, token } = request.body;
  pool.query(
    "UPDATE posts SET post_title = $1, post_content = $2 WHERE user_id = (SELECT user_id FROM users WHERE token = $3) AND post_id = $4 RETURNING post_id",
    [post_title, post_content, token, post_id],
    (error, results) => {
      if (error) {
        response.status(500).json({ error: error });
      }
      response.status(200).json({ 200: `Post modified having Post_ID: ${id}` });
    }
  );
};

router.get("/posts", getPosts);
router.get("/posts/:id", getPostById);
router.post("/posts", createPost);

router.post("/posts", createPost);
router.put("/posts/:id", updatePost);

router.post("/getSubredditPosts", getSubredditPosts);
router.post("/getUserFeedSubredditPosts", getUserFeedSubredditPosts);

module.exports = router;
