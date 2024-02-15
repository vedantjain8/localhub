const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
var cron = require("node-cron");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);

const communityStats = async (request, response) => {
  const community_id = parseInt(request.params.id);

  if (!community_id) {
    return response
      .status(400)
      .json({ status: 400, response: "community id is required" });
  }

  try {
    if (cachingBool) {
      const communityStats = await redisClient.hGet(
        "community_stats_data",
        `community:stats:${community_id}`
      );

      if (communityStats) {
        return response
          .status(200)
          .json({ status: 200, response: JSON.parse(communityStats) });
      }
    }

    const { rows: dbcommunityCount } = await pool.query(
      "SELECT subscriber_count FROM community_stats WHERE community_id= $1 LIMIT 1",
      [community_id]
    );

    if (cachingBool) {
      await redisClient.hSet(
        "community_stats_data",
        `community:stats:${community_id}`,
        JSON.stringify(dbcommunityCount[0])
      );
    }

    return response
      .status(200)
      .json({ status: 200, response: dbcommunityCount[0] });
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error });
  }
};

const postStats = async (request, response) => {
  const post_id = parseInt(request.params.id);

  if (!post_id) {
    return response
      .status(400)
      .json({ status: 400, response: "post id is required" });
  }

  try {
    if (cachingBool) {
      const postStats = await redisClient.hGet(
        "post_stats_data",
        `post:stats:${post_id}`
      );

      if (postStats) {
        const postStatsObject = JSON.parse(postStats);
        return response
          .status(200)
          .json({ status: 200, response: postStatsObject });
      }
    }

    const dbPostStats = await pool.query(
      "SELECT total_votes, total_views, total_comments FROM posts_stats WHERE post_id= $1 LIMIT 1",
      [post_id]
    );

    var postStats = dbPostStats.rows[0];

    if (cachingBool) {
      await redisClient.hSet(
        "post_stats_data",
        `post:stats:${post_id}`,
        JSON.stringify(postStats)
      );
    }

    return response.status(200).json({ status: 200, response: postStats });
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error });
  }
};

router.get("/community/stats/:id", communityStats);
router.get("/post/stats/:id", postStats);

module.exports = router;
