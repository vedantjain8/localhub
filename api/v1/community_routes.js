const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
var validator = require("validator");
const { reservedKeywordsF } = require("../tools");
const { getUserData } = require("./functions/users");
const { getCommunityData } = require("./functions/community");
const config = require("../config/config.json");
var cron = require("node-cron");

const cachingBool = Boolean(config.caching);

// regex for alphanumeric and underscore
const allowedCharactersRegex = /^[a-zA-Z0-9_]*$/;
const createCommunity = async (request, response) => {
  try {
    var {
      community_name,
      community_description,
      logo_url,
      token,
      banner_url = null,
    } = request.body;

    if (
      !community_name ||
      !validator.isLength(community_name, { min: 2, max: 60 }) ||
      !allowedCharactersRegex.test(community_name)
    ) {
      return response
        .status(400)
        .json({ error: "Enter a valid community name" });
    }

    if (reservedKeywordsF().includes(community_name.toLowerCase())) {
      return response.status(400).json({
        error: "community name is a reserved keyword and cannot be used.",
      });
    }

    if (!token) {
      return response
        .status(400)
        .json({ error: "community cant be created without owner user" });
    }

    if (!logo_url) {
      logo_url = `https://api.dicebear.com/7.x/initials/svg?seed=${community_name}`;
    }

    if (!banner_url) {
      banner_url = "https://picsum.photos/1175/235";
    }
    const user_id = JSON.parse(await getUserData(token))["user_id"];

    const community_id = JSON.parse(await getCommunityData(community_name))[
      "community_id"
    ];

    if (community_id) {
      return response
        .status(400)
        .json({ error: "community name is not available" });
    }

    // Create the community
    const createcommunityResult = await pool.query(
      "INSERT INTO community (community_name, community_description, creator_user_id, banner_url, logo_url) VALUES ($1, $2, $3, $4, $5, $6) RETURNING community_id",
      [community_name, community_description, user_id, banner_url, logo_url]
    );

    response.status(200).json({
      200: `community created with ID: ${createcommunityResult.rows[0].community_id}`,
    });
  } catch (error) {
    console.error("Error creating community:", error);
    response.status(500).json({ error: "Error creating community" });
  }
};

const getcommunity = (request, response) => {
  var communityName = request.query.communityName;

  pool.query(
    "SELECT * FROM community WHERE community_name LIKE LOWER($1 || '%') AND active = 'T' ORDER BY community_id ASC LIMIT 8",
    [communityName],
    (error, result) => {
      if (error) {
        console.log(error);
        return response.status(500).json({ error: error });
      }
      response.status(200).json(result.rows);
    }
  );
};

// const getcommunityById = (request, response) => {
//   const community_id = parseInt(request.params.id);

//   if (!community_id) {
//     return response.status(400).json({ error: "Search id is required" });
//   }

//   pool.query(
//     "SELECT * FROM community WHERE community_id = $1",
//     [community_id],
//     (error, results) => {
//       if (error) {
//         response.status(400).json({ error: error });
//       }
//       response.status(200).json(results.rows);
//     }
//   );
// };

const joinCommunity = async (request, response) => {
  const community_id = parseInt(request.body.community_id);
  const token = request.body.token;

  if (!community_id) {
    return response.status(400).json({ error: "community id is required" });
  }

  if (!token) {
    return response.status(400).json({ error: "user token is required" });
  }

  const user_id = JSON.parse(await getUserData(token))["user_id"];

  try {
    // community_user_link & community_stats
    if (cachingBool) {
      redisClient.select(0);

      await redisClient.hSet(
        "user_community_data",
        `user:${user_id}:community:${community_id}`,
        JSON.stringify({
          userId: user_id,
          communityId: community_id,
          joined_at: new Date().toISOString(),
        })
      );

      var value = await redisClient.get(
        `community:joinedCount:${community_id}`
      );
      if (value) {
        value = parseInt(`${value}`);
        await redisClient.set(`community:joinedCount:${community_id}`, ++value);
      }
    } else {
      pool.query(
        "INSERT INTO users_community_link(community_id, user_id) VALUES($1, $2)",
        [community_id, user_id]
      );

      pool.query(
        "UPDATE community_stats SET subscriber_count = subscriber_count + 1 WHERE community_id = $1",
        [community_id]
      );
    }
  } catch (error) {
    console.log("redis failed to insert community:joinedCount");
  }
};

const leaveCommunity = async (request, response) => {
  const community_id = parseInt(request.body.community_id);
  const token = request.body.token;

  if (!community_id) {
    return response.status(400).json({ error: "community id is required" });
  }

  if (!token) {
    return response.status(400).json({ error: "user token is required" });
  }

  const user_id = JSON.parse(await getUserData(token))["user_id"];

  try {
    // community_user_link & community_stats
    if (cachingBool) {
      redisClient.select(0);

      await redisClient.hDel(
        "user_community_data",
        `user:${user_id}:community:${community_id}`
      );

      var value = await redisClient.get(
        `community:joinedCount:${community_id}`
      );

      if (value) {
        value = parseInt(`${value}`);
        await redisClient.set(
          `community:joinedCount:${community_id}`,
          value - 1
        );
      }
    } else {
      pool.query(
        "DELETE FROM users_community_link WHERE user_id = $1 AND community_id = $2",
        [user_id, community_id]
      );

      pool.query(
        "UPDATE community_stats SET subscriber_count = subscriber_count - 1 WHERE community_id = $1",
        [community_id]
      );
    }
  } catch (error) {
    console.log("redis failed to insert community:joinedCount");
  }
};

// used to send data to db from redis
cron.schedule("*/10 * * * *", async () => {
  // running task every 10 minutes
  if (cachingBool) {
    console.log("community cron running");

    // user community link insert
    const userData = await redisClient.hGetAll(
      "user_community_data",
      "user:*:community:*"
    );

    for (const singleData in userData) {
      data = JSON.parse(userData[singleData]);
      pool.query(
        "INSERT INTO user_community_link (user_id, community_id, joined_at) VALUES ($1, $2, $3)",
        [data.userId, data.communityId, data.joined_at]
      );
      await redisClient.hDel(
        "user_community_data",
        `user:${data.userId}:community:${data.communityId}`
      );
    }

    // community_stats
    var value = await redisClient.keys(`community:joinedCount:*`);

    for (i in value) {
      var community_id = value[i].split(":")[2];
      var newCount = await redisClient.get(`${value[i]}`);
      if (newCount) {
        newCount = parseInt(`${newCount}`);
        pool.query(
          "UPDATE community_stats SET subscriber_count = subscriber_count + $2 WHERE community_id = $1",
          [community_id, newCount]
        );
      }
    }
  }
});

router.get("/community", getcommunity);
// router.get("/community/:id", getcommunityById);
router.post("/community", createCommunity);
router.post("/community/join", joinCommunity);
router.post("/community/leave", leaveCommunity);

module.exports = router;
