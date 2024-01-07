const pool = require("../../db");
const redisClient = require("../../dbredis");
const config = require("../../config/config.json");

const cachingBool = Boolean(config.caching);

async function incrementView(postId, userId) {
  if (cachingBool)
    try {
      const hashKey = `postid:${postId}:${userId}`;
      const exists = await redisClient.exists(hashKey).then(Boolean);

      if (!exists) {
        await redisClient.hset(hashKey, "timestamp", Date.now());
        await redisClient.expire(hashKey, 86400); // Expire after 24 hours

        pool.query(
          "UPDATE posts_stats SET total_views = total_views + 1 WHERE post_id = $1",
          [postId]
        );
      }
    } catch (error) {
      console.error("error view count increment:", error);
    }
}

module.exports = { incrementView };
