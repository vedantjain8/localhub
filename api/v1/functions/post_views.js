const pool = require("../../db");
const redisClient = require("../../dbredis");
const config = require("../../config/config.json");

const cachingBool = Boolean(config.caching);

async function incrementView(postId, userId) {
  if (cachingBool)
    try {

      const rateLimitCheck = await redisClient.get(
        `rateLimit:postID-${postId}:userID-${userId}`
      );

      if (rateLimitCheck) {
        return;
      }
      // create new ratelimit for post cache
      await redisClient.setEx(
        `rateLimit:postID-${postId}:userID-${userId}`,
        5400,
        "T"
      );

      // below coode block will increment view in redis cache
      const postStats = await redisClient.hGet(
        "post_stats_data",
        `post:stats:${postId}`
      );

      if (postStats) {
        const postStatsObject = JSON.parse(postStats);
        postStatsObject["total_views"] += 1;

        await redisClient.hSet(
          "post_stats_data",
          `post:stats:${postId}`,
          JSON.stringify(postStatsObject)
        );
      }
    } catch (error) {
      console.error(error);
    }
}

module.exports = { incrementView };
