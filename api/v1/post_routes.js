const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
const { getUserData } = require("./functions/users");
const { getCommunityData } = require("./functions/community");
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
      post_content,
      post_image,
      is_adult,
      community_name,
      token,
    } = request.body;

    if (!token) {
      return response.status(400).json({ error: "Token is required" });
    }

    if (post_image == "") {
      post_image = null;
    }

    if (!community_name) {
      return response.status(400).json({ error: "Community name is required" });
    }

    if (
      !post_title ||
      !validator.isLength(post_title, { min: 5, max: 200 }) ||
      !allowedCharactersRegex.test(post_title)
    ) {
      return response.status(400).json({ error: "Enter a valid post title" });
    }

    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (!user_id) {
      return response.status(400).json({ error: "Invalid  name provided" });
    }

    const community_id = JSON.parse(await getCommunityData(community_name))[
      "community_id"
    ];

    if (!community_id) {
      return response
        .status(400)
        .json({ error: "Invalid community name provided" });
    }
    // Create the post
    const createPostResult = await pool.query(
      "INSERT INTO posts (post_title, post_content, post_image, user_id, community_id, is_adult) VALUES ($1, $2, $3, $4, $5, $6) RETURNING post_id",
      [post_title, post_content, post_image, user_id, community_id, is_adult]
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
          LEFT(posts.post_content, 159) as short_content,
          posts.post_image,
          posts.community_id,
          posts.created_at,
          community.community_name,
          community.logo_url
        FROM
          posts
        JOIN
          community ON posts.community_id = community.community_id
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
      await redisClient.set(`posts:offset-${offset}`, JSON.stringify(userData));
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
  var community_id = request.body.community_id;

  if (!offset) {
    offset = 0;
  }

  if (!community_id) {
    return response.status(400).json({ error: "community_id is required" });
  }

  try {
    if (cachingBool) {
      redisClient.select(0);
      const value = await redisClient.get(
        `community-${community_id}:posts:offset-${offset}`
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
      LEFT(posts.post_content, 159) as short_content,
      posts.post_image,
      posts.community_id,
      posts.is_adult,
      posts.created_at,
      community.community_name,
      community.logo_url
    FROM
        posts
    JOIN
        community ON posts.community_id = community.community_id
    WHERE
        posts.active = 'T'
        AND posts.community_id = $1 
        AND community.community_id = $1
    ORDER BY
        posts.created_at DESC
    LIMIT 20
    OFFSET $2`,
      [community_id, offset]
    );

    // Store data in Redis if caching is enabled
    if (cachingBool) {
      redisClient.set(
        `community-${community_id}:posts:offset-${offset}`,
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

  const user_id = JSON.parse(await getUserData(token))["user_id"];

  if (!user_id) {
    return response.status(400).json({ error: "Invalid  name provided" });
  }

  try {
    pool.query(
      `SELECT
    posts.post_id,
    posts.post_title,
    LEFT(posts.post_content, 159) as short_content,
    posts.post_image,
    posts.community_id,
    posts.created_at,
    community.community_name,
    community.logo_url
FROM
    posts
JOIN
    subreddit ON posts.community_id = community.community_id
JOIN
    users_community_link ON posts.community_id = users_community_link.community_id
WHERE
    posts.active = 'T'
    AND user_community_link.user_id = $1
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
        users.username AS post_username,
        posts.post_title,
        posts.post_content,
        posts.post_image,
        posts.community_id,
        posts.created_at,
        community.community_name,
        community.logo_url
    FROM
        posts
    JOIN
        community ON posts.community_id = community.community_id
    JOIN
        users ON posts.user_id = users.user_id
   WHERE
        posts.active = 'T' AND posts.post_id = $1`,
      [post_id]
    );

    if (cachingBool) {
      await redisClient.set(
        `posts:postID-${post_id}`,
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

// TODO create update post endpoint
// const updatePost = (request, response) => {
//   const post_id = parseInt(request.params.id);
//   const { post_title, post_content, token } = request.body;
//   pool.query(
//     "UPDATE posts SET post_title = $1, post_content = $2 WHERE user_id = (SELECT user_id FROM users WHERE token = $3) AND post_id = $4 RETURNING post_id",
//     [post_title, post_content, token, post_id],
//     (error, results) => {
//       if (error) {
//         response.status(500).json({ error: error });
//       }
//       response.status(200).json({ 200: `Post modified having Post_ID: ${id}` });
//     }
//   );
// };

const getUserPubPosts = async (request, response) => {
  var offset = parseInt(request.body.offset);
  var token = request.body.token;

  if (!offset) {
    offset = 0;
  }

  if (!token) {
    return response.status(400).json({ error: "Provide a user token" });
  }

  const user_id = JSON.parse(await getUserData(token))["user_id"];

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
    LEFT(posts.post_content, 159) as short_content,
    posts.post_image,
    posts.community_id,
    posts.is_adult,
    posts.created_at,
    community.community_name,
    community.logo_url,
  FROM
    posts
  INNER JOIN
    subreddit ON posts.subreddit_id = subreddit.subreddit_id
  WHERE
    posts.user_id = $1
      AND
    posts.active = 'T'
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

router.get("/posts", getPosts);
router.get("/posts/:id", getPostById);

router.post("/posts", createPost);
router.post("/users/posts", getUserPubPosts);

// TODO
// router.put("/posts/:id", updatePost);

router.post("/getSubredditPosts", getSubredditPosts);
router.post("/getUserFeedSubredditPosts", getUserFeedSubredditPosts);

module.exports = router;
