const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
const { getUserData } = require("./functions/users");
const { getCommunityData } = require("./functions/community");
const { incrementView } = require("./functions/post_views");
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
      return response
        .status(400)
        .json({ status: 400, response: "Token is required" });
    }

    if (post_image == null || post_image == "null") {
      post_image = "";
    }

    if (!community_name) {
      return response
        .status(400)
        .json({ status: 400, response: "Community name is required" });
    }

    if (!is_adult) {
      is_adult = false;
    }

    if (
      !post_title ||
      !validator.isLength(post_title, { min: 5, max: 200 }) ||
      !allowedCharactersRegex.test(post_title)
    ) {
      return response
        .status(400)
        .json({ status: 400, response: "Enter a valid post title" });
    }

    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (!user_id) {
      return response
        .status(401)
        .json({ status: 401, response: "Token is not valid" });
    }

    const community_id = JSON.parse(await getCommunityData(community_name))[
      "community_id"
    ];

    if (!community_id) {
      return response
        .status(400)
        .json({ status: 400, response: "Invalid community name provided" });
    }
    // Create the post
    const createPostResult = await pool.query(
      `INSERT INTO
      posts (
        post_title,
        post_content,
        post_image,
        user_id,
        community_id,
        is_adult
      )
    VALUES
      ($1, $2, $3, $4, $5, $6) RETURNING post_id`,
      [post_title, post_content, post_image, user_id, community_id, is_adult]
    );

    if (cachingBool) {
      // Get all keys matching the pattern 'post:offset-*'
      const keys = await redisClient.keys("posts:offset-*");

      // Delete each key
      const deletePromises = keys.map((key) => redisClient.del(key));

      // Wait for all keys to be deleted
      await Promise.all(deletePromises);
    }

    return response.status(200).json({
      status: 200,
      response: `Post added with ID - ${createPostResult.rows[0].post_id}`,
    });
  } catch (error) {
    console.error(error);
    return response.status(500).json({ status: 500, response: error });
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
        return response
          .status(200)
          .json({ status: 200, response: JSON.parse(value) }); // Data found in Redis
      }
    }

    // Data not found in Redis or caching is disabled, fetch from PostgreSQL
    const { rows: userData } = await pool.query(
      `SELECT
          posts.post_id,
          posts.post_title,
          users.username AS post_username,
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
        JOIN
          users ON posts.user_id = users.user_id
        WHERE
          posts.active = 'T'
          AND community.active = 'T'
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

    return response.status(200).json({ status: 200, response: userData });
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error.message });
  }
};

const getCommunityPosts = async (request, response) => {
  var offset = parseInt(request.query.offset);
  var community_id = request.body.community_id;

  if (!offset) {
    offset = 0;
  }

  if (offset % 20 !== 0) {
    return response
      .status(400)
      .json({ status: 400, response: "offset should be 20 multiple only" });
  }

  if (!community_id) {
    return response
      .status(400)
      .json({ status: 400, response: "community_id is required" });
  }

  try {
    if (cachingBool) {
      redisClient.select(0);
      const value = await redisClient.get(
        `community:${community_id}:posts:offset-${offset}`
      );
      if (value) {
        return response
          .status(200)
          .json({ status: 200, response: JSON.parse(value) }); // Data found in Redis
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
        AND community.active = 'T'
    ORDER BY
        posts.created_at DESC
    LIMIT 20
    OFFSET $2`,
      [community_id, offset]
    );

    // Store data in Redis if caching is enabled
    if (cachingBool) {
      redisClient.set(
        `community:${community_id}:posts:offset-${offset}`,
        JSON.stringify(userData)
      );
    }

    return response.status(200).json({ status: 200, response: userData });
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error.message });
  }
};

const getUserFeedPosts = async (request, response) => {
  try {
    var { offset } = parseInt(request.body.offset);
    var token = request.body.token;

    if (!offset) {
      offset = 0;
    }

    if (!token || token == null || token == "" || token == undefined) {
      return response
        .status(400)
        .json({ status: 400, response: "Provide a user token" });
    }

    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (!user_id) {
      return response
        .status(401)
        .json({ status: 401, response: "Token is not valid" });
    }

    mergedList = [];

    if (cachingBool) {
      const communityJoinedFromCache = await redisClient.hGetAll(
        "user_community_data",
        `user:${user_id}:community:*`
      );
      for (const singleData in communityJoinedFromCache) {
        data = JSON.parse(communityJoinedFromCache[singleData]);
        mergedList.push(data.communityId);
      }
    }

    const communityJoinedFromDB = await pool.query(
      "SELECT community_id FROM users_community_link WHERE user_id = $1",
      [user_id]
    );

    // Extract community IDs from the database query result and push them to the mergedList array
    const communityIdsFromDB = communityJoinedFromDB.rows.map(
      (row) => row.community_id
    );
    mergedList.push(...communityIdsFromDB);

    pool.query(
      `SELECT
      posts.post_id,
      posts.post_title,
      LEFT(posts.post_content, 159) as short_content,
      posts.post_image,
      posts.community_id,
      posts.created_at,
      community.community_name,
      community.logo_url,
      users.username AS post_username
  FROM
      posts
  JOIN
      community ON posts.community_id = community.community_id
  JOIN
      users on posts.user_id = users.user_id
  WHERE
      posts.active = 'T'
      AND community.active = 'T'
      AND posts.community_id IN (${mergedList.join(",")})
  ORDER BY
      posts.created_at DESC
  LIMIT 20
  OFFSET $1
`,
      [offset],
      async (error, result) => {
        if (error) {
          console.error(error);
          return response.status(500).json({ status: 500, response: error });
        }
        userData = result.rows;
        return response.status(200).json({ status: 200, response: userData });
      }
    );
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error.message });
  }
};

const getPostById = async (request, response) => {
  const post_id = parseInt(request.params.id);
  const token = request.body.token || null;

  if (!post_id) {
    return response
      .status(400)
      .json({ status: 400, response: "post id is required" });
  }

  try {
    if (cachingBool) {
      redisClient.select(0);

      const value = await redisClient.get(`posts:postID-${post_id}`);

      if (value) {
        // Data found in Redis, parse and send response
        return response
          .status(200)
          .json({ status: 200, response: JSON.parse(value) });
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
        posts.active = 'T' AND community.active = 'T' AND  posts.post_id = $1`,
      [post_id]
    );

    const data = userData;

    if (token) {
      const user_id = JSON.parse(await getUserData(token))["user_id"];
      if (user_id) {
        incrementView(post_id, user_id);
      }
    }

    if (cachingBool) {
      await redisClient.set(`posts:postID-${post_id}`, JSON.stringify(data));
    }

    return response.status(200).json({ status: 200, response: data });
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error.message });
  }
};

const updatePost = async (request, response) => {
  const post_id = parseInt(request.params.id);
  const { post_title, post_content, post_image, is_adult, active, token } =
    request.body;

  if (!post_id) {
    return response
      .status(400)
      .json({ status: 400, response: "Provide a valid post_id" });
  }

  if (!token) {
    return response
      .status(400)
      .json({ status: 400, response: "Provide a user token" });
  }

  const user_id = JSON.parse(await getUserData(token))["user_id"];

  if (!user_id) {
    return response
      .status(401)
      .json({ status: 401, response: "Token is not valid" });
  }

  if (
    !post_title ||
    !validator.isLength(post_title, { min: 5, max: 200 }) ||
    !allowedCharactersRegex.test(post_title)
  ) {
    return response
      .status(400)
      .json({ status: 400, response: "Enter a valid post title" });
  }

  // Construct the SET clause dynamically based on provided fields
  const setClause = [];
  const values = [post_id];

  if (post_title !== undefined) {
    setClause.push(`post_title = $${values.push(post_title)}`);
  }

  if (post_content !== undefined) {
    setClause.push(`post_content = $${values.push(post_content)}`);
  }

  if (post_image !== undefined && post_image !== "") {
    setClause.push(`post_image = $${values.push(post_image)}`);
  }

  if (is_adult !== undefined) {
    setClause.push(`is_adult = $${values.push(is_adult)}`);
  }

  if (active !== undefined) {
    setClause.push(`active = $${values.push(active)}`);
  }

  // Check if any valid fields were provided
  if (setClause.length === 0) {
    return response
      .status(400)
      .json({ status: 400, response: "No valid fields provided for update." });
  }

  const updateQuery = `UPDATE posts SET ${setClause.join(
    ", "
  )} WHERE user_id = ${user_id} AND post_id = $1 RETURNING post_id`;

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
        response: `Post with ID ${post_id} not found for the user.`,
      });
    }

    if (cachingBool) {
      // Get all keys matching the pattern 'post:offset-*'
      const keys = await redisClient.keys("posts:offset-*");

      // Delete each key
      const deletePromises = keys.map((key) => redisClient.del(key));

      // Wait for all keys to be deleted
      await Promise.all(deletePromises);

      await redisClient.del(`posts:postID-${post_id}`);
    }

    response.status(200).json({
      status: 200,
      response: `Post modified having Post_ID: ${post_id}`,
    });
  });
};

const getUserPubPosts = async (request, response) => {
  var offset = parseInt(request.body.offset);
  var token = request.body.token;

  if (!offset) {
    offset = 0;
  }

  if (!token) {
    return response
      .status(400)
      .json({ status: 400, response: "Provide a user token" });
  }

  const user_id = JSON.parse(await getUserData(token))["user_id"];

  if (!user_id) {
    return response
      .status(401)
      .json({ status: 401, response: "Token is not valid" });
  }

  try {
    if (cachingBool) {
      redisClient.select(0);

      value = await redisClient.get(`postsPubBy:userID-${user_id}:${offset}`);

      if (value) {
        // Data found in Redis, parse and send response
        return response
          .status(200)
          .json({ status: 200, response: JSON.parse(value) });
      }
    }
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
    community.logo_url
  FROM
    posts
  JOIN
    community ON posts.community_id = community.community_id
  WHERE
    posts.user_id = $1
      AND
    posts.active = 'T'
    AND community.active = 'T'
  ORDER BY
    posts.created_at DESC
  LIMIT 20
  OFFSET $2`,
      [user_id, offset],
      (error, result) => {
        if (error) {
          console.error(error);
          return response.status(500).json({ status: 500, response: error });
        }
        userData = result.rows;
        if (cachingBool) {
          redisClient.setEx(
            `postsPubBy:userID-${user_id}:${offset}`,
            1800,
            JSON.stringify(userData)
          );
        }
        return response.status(200).json({ status: 200, response: userData });
      }
    );
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error.message });
  }
};

const deletePost = async (request, response) => {
  const post_id = parseInt(request.params.id);
  const token = request.body.token;

  if (!post_id) {
    return response
      .status(400)
      .json({ status: 400, response: "post id is required" });
  }

  if (!token) {
    return response
      .status(400)
      .json({ status: 400, response: "Provide a user token" });
  }

  const user_id = JSON.parse(await getUserData(token))["user_id"];

  if (!user_id) {
    return response
      .status(401)
      .json({ status: 401, response: "Token is not valid" });
  }

  try {
    pool.query(
      `UPDATE posts SET active = false WHERE user_id = $1 and post_id = $2 RETURNING post_id`,
      [user_id, post_id],
      async (error, result) => {
        if (error) {
          console.error(error);
          return response.status(500).json({ status: 500, response: error });
        }
        userData = result.rows;

        if (userData.length == 0) {
          return response
            .status(400)
            .json({ status: 400, response: "No post found" });
        }
        if (cachingBool) {
          // Get all keys matching the pattern 'post:offset-*'
          const keys = await redisClient.keys("posts:offset-*");
          const keysforPubPostByUser = await redisClient.keys(
            `postsPubBy:userID-${user_id}:*`
          );

          // Delete each key
          const deletePromises = keys.map((key) => redisClient.del(key));
          const deletePromisesforPubPostByUser = keysforPubPostByUser.map(
            (key) => redisClient.del(key)
          );

          // Wait for all keys to be deleted
          await Promise.all(deletePromises);
          await Promise.all(deletePromisesforPubPostByUser);
          await redisClient.del(`posts:postID-${post_id}`);
        }
        return response.status(200).json({ status: 200, response: userData });
      }
    );
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error.message });
  }
};

router.get("/posts", getPosts);
router.post("/posts/:id", getPostById);

router.post("/posts", createPost);
router.post("/posts-by-user/", getUserPubPosts);

router.put("/posts/:id", updatePost);
router.delete("/posts/:id", deletePost);

router.post("/community/posts", getCommunityPosts);
router.post("/getUserFeedPosts", getUserFeedPosts);

module.exports = router;
