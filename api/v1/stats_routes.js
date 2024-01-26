const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
var cron = require("node-cron");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);

const communityStats = async (request, response) => {
  const community_id = parseInt(request.body.community_id);

  if (!community_id) {
    return response.status(400).json({ error: "community id is required" });
  }

  try {
    if (cachingBool) {
      communityCount = await redisClient.get(`community:stats:${community_id}`);
      return response.status(200).json(JSON.parse(communityCount));
    }

    const { dbcommunityCount } = await pool.query(
      "SELECT subscriber_count FROM community_stats WHERE community_id= $1 LIMIT 1",
      [community_id]
    );

    var communityCount = dbcommunityCount.rows[0];

    if (cachingBool) {
      await redisClient.set(
        `community:stats:${community_id}`,
        JSON.stringify(communityCount)
      );
    }

    return response.status(200).json(communityCount);
  } catch (error) {
    return response.status(400).json(error);
  }
};

const postStats = async (request, response) => {
  const post_id = parseInt(request.params.id);

  if (!post_id) {
    return response.status(400).json({ error: "post id is required" });
  }

  try {
    if (cachingBool) {
      const postStats = await redisClient.hGet(
        "post_stats_data",
        `post:stats:${post_id}`
      );

      if (postStats) {
        const postStatsObject = JSON.parse(postStats);
        return response.status(200).json(postStatsObject);
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
      // await redisClient.set(`post:stats:${post_id}`, JSON.stringify(postStats));
    }

    return response.status(200).json(postStats);
  } catch (error) {
    console.log(error);
    return response.status(400).json(error);
  }
};

router.post("/community/stats", communityStats);
router.get("/post/stats/:id", postStats);

module.exports = router;
