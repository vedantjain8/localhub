const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
var validator = require("validator");
const { reservedKeywordsFile } = require("../tools");
const { getUserData } = require("./functions/users");
const { getCommunityData } = require("./functions/community");
const config = require("../config/config.json");
var cron = require("node-cron");
const { checkJoinedCommunity } = require("./functions/joinCommunityCheck");
const cachingBool = Boolean(config.caching);

// regex for alphanumeric and underscore
const allowedCharactersRegex = /^[a-zA-Z0-9_]*$/;
const createCommunity = async (request, response) => {
  try {
    var { community_name, community_description, logo_url, token, banner_url } =
      request.body;

    if (
      !community_name ||
      !validator.isLength(community_name, { min: 2, max: 60 }) ||
      !allowedCharactersRegex.test(community_name)
    ) {
      return response
        .status(400)
        .json({ status: 400, response: "Enter a valid community name" });
    }

    if (reservedKeywordsFile().includes(community_name.toLowerCase())) {
      return response.status(400).json({
        status: 400,
        response: "community name is a reserved keyword and cannot be used.",
      });
    }

    if (!token) {
      return response.status(400).json({
        status: 400,
        response: "community cant be created without owner user",
      });
    }

    if (!logo_url) {
      return response.status(400).json({
        status: 400,
        response: "community needs a logo",
      });
    }

    if (!banner_url || banner_url == null) {
      banner_url = "https://picsum.photos/1175/235";
    }
    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (!user_id) {
      return response
        .status(401)
        .json({ status: 401, response: "Token is not valid" });
    }

    const community_id = (await getCommunityData(community_name)) || null;

    if (community_id) {
      return response
        .status(400)
        .json({ status: 400, response: "community name is not available" });
    }

    // Create the community
    const createcommunityResult = await pool.query(
      "INSERT INTO community (community_name, community_description, creator_user_id, banner_url, logo_url) VALUES ($1, $2, $3, $4, $5) RETURNING community_id",
      [community_name, community_description, user_id, banner_url, logo_url]
    );

    return response.status(200).json({
      status: 200,
      response: `community created with ID: ${createcommunityResult.rows[0].community_id}`,
    });
  } catch (error) {
    console.error(error);
    return response
      .status(500)
      .json({ status: 500, response: "Error creating community" });
  }
};

const communitySearch = (request, response) => {
  var communityName = request.query.communityName;

  pool.query(
    "SELECT * FROM community WHERE LOWER(community_name) LIKE LOWER($1 || '%') AND active = 'T' ORDER BY community_id ASC LIMIT 8",
    [communityName],
    (error, result) => {
      if (error) {
        console.error(error);
        return response.status(500).json({ status: 500, response: error });
      }
      return response.status(200).json({ status: 200, response: result.rows });
    }
  );
};

const getcommunityDataById = async (request, response) => {
  const community_id = parseInt(request.params.id);

  if (!community_id) {
    return response
      .status(400)
      .json({ status: 400, response: "Search id is required" });
  }

  try {
    if (cachingBool) {
      const communityData = await redisClient.hGet(
        "community_data",
        `community:${community_id}`
      );

      if (communityData) {
        return response
          .status(200)
          .json({ status: 200, response: JSON.parse(communityData) });
      }
    }

    const dbCommunityData = await pool.query(
      "SELECT * FROM community WHERE community_id = $1",
      [community_id]
    );

    const communityData = dbCommunityData.rows[0];

    if (cachingBool) {
      await redisClient.hSet(
        "community_data",
        `community:${community_id}`,
        JSON.stringify(communityData)
      );
    }

    return response.status(200).json({ status: 200, response: communityData });
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error });
  }
};

const joinCommunityStatus = async (request, response) => {
  const community_id = parseInt(request.body.community_id);
  const token = request.body.token;

  if (!community_id) {
    return response
      .status(400)
      .json({ status: 400, response: "community id is required" });
  }

  if (!token) {
    return response
      .status(400)
      .json({ status: 400, response: "user token is required" });
  }

  const user_id = JSON.parse(await getUserData(token))["user_id"];

  if (!user_id) {
    return response
      .status(401)
      .json({ status: 401, response: "Token is not valid" });
  }

  try {
    const checkBool = await checkJoinedCommunity(community_id, user_id);

    return response
      .status(200)
      .json({ status: 200, response: [{ exists: checkBool }] });
  } catch (error) {
    return response.status(400).json({ status: 400, response: error });
  }
};

const joinCommunity = async (request, response) => {
  const community_id = parseInt(request.body.community_id);
  const token = request.body.token;

  if (!community_id) {
    return response
      .status(400)
      .json({ status: 400, response: "community id is required" });
  }

  if (!token) {
    return response
      .status(400)
      .json({ status: 400, response: "user token is required" });
  }

  const user_id = JSON.parse(await getUserData(token))["user_id"];

  if (!user_id) {
    return response
      .status(401)
      .json({ status: 401, response: "Token is not valid" });
  }

  try {
    // community_user_link & community_stats

    const checkBool = await checkJoinedCommunity(community_id, user_id);

    if (checkBool == false) {
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

        var value = JSON.parse(
          await redisClient.hGet(
            "community_stats_data",
            `community:stats:${community_id}`
          )
        );

        if (value) {
          valueCount = parseInt(`${value["subscriber_count"]}`);
          await redisClient.hSet(
            "community_stats_data",
            `community:stats:${community_id}`,
            JSON.stringify({ subscriber_count: ++valueCount })
          );
        } else
          await redisClient.hSet(
            "community_stats_data",
            `community:stats:${community_id}`,
            JSON.stringify({ subscriber_count: 1 })
          );

        return response
          .status(200)
          .json({ status: 200, response: "Successfully joined the community" });
      } else {
        pool.query(
          "INSERT INTO users_community_link(community_id, user_id) VALUES($1, $2)",
          [community_id, user_id]
        );

        pool.query(
          "UPDATE community_stats SET subscriber_count = subscriber_count + 1 WHERE community_id = $1",
          [community_id]
        );

        return response
          .status(200)
          .json({ status: 200, response: "Successfully joined the community" });
      }
    }
    return response
      .status(200)
      .json({ status: 200, response: "Already joined the community" });
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error });
  }
};

const leaveCommunity = async (request, response) => {
  const community_id = parseInt(request.body.community_id);
  const token = request.body.token;

  if (!community_id) {
    return response
      .status(400)
      .json({ status: 400, response: "community id is required" });
  }

  if (!token) {
    return response
      .status(400)
      .json({ status: 400, response: "user token is required" });
  }

  const user_id = JSON.parse(await getUserData(token))["user_id"];

  if (!user_id) {
    return response
      .status(401)
      .json({ status: 401, response: "Token is not valid" });
  }

  try {
    // community_user_link & community_stats

    const checkBool = await checkJoinedCommunity(community_id, user_id);

    if (checkBool == true) {
      if (cachingBool) {
        redisClient.select(0);

        const isUserJoinedInCache = await redisClient.hGet(
          "user_community_data",
          `user:${user_id}:community:${community_id}`
        );

        if (isUserJoinedInCache) {
          await redisClient.hDel(
            "user_community_data",
            `user:${user_id}:community:${community_id}`
          );
        } else {
          pool.query(
            "DELETE FROM users_community_link WHERE user_id = $1 AND community_id = $2",
            [user_id, community_id]
          );
        }

        var value = JSON.parse(
          await redisClient.hGet(
            "community_stats_data",
            `community:stats:${community_id}`
          )
        );
        if (value) {
          valueCount = parseInt(`${value["subscriber_count"]}`);
          await redisClient.hSet(
            "community_stats_data",
            `community:stats:${community_id}`,
            JSON.stringify({ subscriber_count: --valueCount })
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
      return response
        .status(200)
        .json({ status: 200, response: "Successfully left the community" });
    }
    return response.status(200).json({
      status: 400,
      response: "Community was not joined before leaving!",
    });
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error });
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
        "INSERT INTO users_community_link (user_id, community_id, joined_at) VALUES ($1, $2, $3)",
        [data.userId, data.communityId, data.joined_at]
      );
      await redisClient.hDel(
        "user_community_data",
        `user:${data.userId}:community:${data.communityId}`
      );
    }

    // community_stats
    if (cachingBool) {
      var value = await redisClient.hGetAll("community_stats_data", "*");

      for (singleCommunity in value) {
        var community_id = singleCommunity.split(":")[2];
        data = JSON.parse(value[singleCommunity]);
        await pool.query(
          "UPDATE community_stats SET subscriber_count = $1 WHERE community_id = $2",
          [data.subscriber_count, community_id]
        );
      }
    }
  }
});

// upload image cron job
cron.schedule("*/20 * * * *", async () => {
  // running task every 20 minutes
  if (cachingBool) {
    if (cachingBool) {
      console.log("upload image log cron running");

      // user community link insert
      const imageLogData = await redisClient.hGetAll("ImageUploadLog", "*");
      for (const singleData in imageLogData) {
        data = JSON.parse(imageLogData[singleData]);

        pool.query(
          "INSERT INTO image_upload_log (user_id, image_name, image_url) VALUES ($1, $2, $3)",
          [data.user_id, data.image_name, data.image_url],
          (error, result) => {
            if (error) {
              console.error(error);
            }
          }
        );
        await redisClient.hDel("ImageUploadLog", `${singleData}`);
      }
    }
  }
});

router.get("/community/search", communitySearch);
router.get("/community/:id", getcommunityDataById);
router.post("/community", createCommunity);
router.post("/community/check/join", joinCommunityStatus);
router.post("/community/join", joinCommunity);
router.post("/community/leave", leaveCommunity);

module.exports = router;
