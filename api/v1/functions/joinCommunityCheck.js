const pool = require("../../db");
const redisClient = require("../../dbredis");
const config = require("../../config/config.json");
const cachingBool = Boolean(config.caching);

async function checkJoinedCommunity(community_id, user_id) {
    // return bool
  try {
    if (cachingBool) {
      // create user community join check from redis
      const joinData = await redisClient.hGet(
        "user_community_data",
        `user:${user_id}:community:${community_id}`
      );

      if (joinData) {
        return true;
      }
    }
    const { rows: responseBool } = await pool.query(
      "SELECT EXISTS(SELECT user_id FROM users_community_link WHERE user_id = $1 AND community_id = $2 LIMIT 1)",
      [user_id, community_id]
    );
    return responseBool[0].exists;
  } catch (error) {return error}
}

module.exports = { checkJoinedCommunity };
