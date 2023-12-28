const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
var validator = require("validator");
const { reservedKeywordsF } = require("../tools");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);

// regex for alphanumeric and underscore
const allowedCharactersRegex = /^[a-zA-Z0-9_]*$/;
const createSubReddit = async (request, response) => {
  try {
    const {
      subreddit_name,
      subreddit_description = "",
      logo_url,
      token,
      is_adult = false,
      banner_url = null,
    } = request.body;

    if (
      !subreddit_name ||
      !validator.isLength(subreddit_name, { min: 2, max: 60 }) ||
      !allowedCharactersRegex.test(subreddit_name)
    ) {
      return response
        .status(400)
        .json({ error: "Enter a valid subreddit name" });
    }

    if (reservedKeywordsF().includes(subreddit_name.toLowerCase())) {
      return response.status(400).json({
        error: "Subreddit name is a reserved keyword and cannot be used.",
      });
    }

    if (!token) {
      return response
        .status(400)
        .json({ error: "Subreddit cant be created without owner user" });
    }

    if (!logo_url) {
      return response.status(400).json({ error: "logo_url is required field" });
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

    // Check if the subreddit name is available
    const subredditResult = await pool.query(
      "SELECT * FROM subreddit WHERE LOWER(subreddit_name) = LOWER($1)",
      [subreddit_name]
    );

    if (subredditResult.rows.length > 0) {
      return response
        .status(400)
        .json({ error: "Subreddit name is not available" });
    }

    // Create the subreddit
    const createSubredditResult = await pool.query(
      "INSERT INTO subreddit (subreddit_name, subreddit_description, creator_user_id, is_adult, banner_url, logo_url) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING subreddit_id",
      [
        subreddit_name,
        subreddit_description,
        user_id,
        is_adult,
        banner_url,
        logo_url,
      ]
    );

    response.status(200).json({
      200: `Subreddit created with ID: ${createSubredditResult.rows[0].subreddit_id}`,
    });
  } catch (error) {
    console.error("Error creating Subreddit:", error);
    response.status(500).json({ error: "Error creating Subreddit" });
  }
};

const getSubreddits = (request, response) => {
  var subredditName = request.query.subredditName;

  pool.query(
    "SELECT * FROM subreddit WHERE subreddit_name LIKE LOWER($1 || '%') AND active = 'T' ORDER BY subreddit_id ASC LIMIT 8",
    [subredditName],
    (error, result) => {
      if (error) {
        console.log(error);
        return response.status(500).json({ error: error });
      }
      response.status(200).json(result.rows);
    }
  );
};

// const getSubredditById = (request, response) => {
//   const subreddit_id = parseInt(request.params.id);

//   if (!subreddit_id) {
//     return response.status(400).json({ error: "Search id is required" });
//   }

//   pool.query(
//     "SELECT * FROM subreddit WHERE subreddit_id = $1",
//     [subreddit_id],
//     (error, results) => {
//       if (error) {
//         response.status(400).json({ error: error });
//       }
//       response.status(200).json(results.rows);
//     }
//   );
// };

const joinSubreddit = async (request, response) => {
  const subreddit_id = parseInt(request.body.subreddit_id);
  const token = request.body.token;
  const status = request.body.token;

  if (!subreddit_id) {
    return response.status(400).json({ error: "Subreddit id is required" });
  }

  if (!token) {
    return response.status(400).json({ error: "user token is required" });
  }

  if (!status) {
    return response
      .status(400)
      .json({ error: "join or leave status is required" });
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

  // ========SUBREDDIT JOIN Count REDIS========
  try {
    if (cachingBool) {
      redisClient.select(0);

      var value = await redisClient.get(
        `community:joinedCount:${subreddit_id}`
      );
      if (value) {
        value = parseInt(`${value}`);
        await redisClient.set(`community:joinedCount:${subreddit_id}`, ++value);
      }
    } else {
      pool.query(
        "UPDATE community_stats SET subscriber_count = subscriber_count + 1 WHERE community_id = $1",
        [subreddit_id]
      );
    }

    // ===================================

    pool.query(
      "INSERT INTO user_subreddit_link (user_id, subreddit_id) VALUES ($1, $2)",
      [user_id, subreddit_id],
      (error, results) => {
        if (error) {
          if (error.code === "23505") {
            // Unique violation error, the record already exists
            response
              .status(409)
              .json({ status: "User already joined this subreddit" });
          } else {
            // Other error
            response.status(400).json({ status: "Error joining subreddit" });
          }
        } else {
          // Successfully inserted
          response
            .status(200)
            .json({ status: "Successfully joined subreddit" });
        }
      }
    );
  } catch (error) {
    console.log("redis failed to insert community:joinedCount");
  }
};

router.get("/subreddit", getSubreddits);
// router.get("/subreddit/:id", getSubredditById);
router.post("/subreddit", createSubReddit);
router.post("/joinSubreddit", joinSubreddit);

module.exports = router;
