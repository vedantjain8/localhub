const pool = require("../../db");
const redisClient = require("../../dbredis");
const config = require("../../config/config.json");

const cachingBool = Boolean(config.caching);

async function getCommunityData(communityName) {
  // Return list of users data based on users token
  try {
    if (cachingBool) {
      redisClient.select(0);

      var value = await redisClient.get(`community:${communityName}`);

      if (value) {
        // Data found in Redis, parse and send response
        return value;
      }
    }
    // Data not found in Redis, fetch from PostgreSQL
    const communityResult = await pool.query(
      "SELECT community_id, community_name, community_description, creator_user_id, created_at, banner_url, logo_url from community where LOWER(community_name) = LOWER($1) and community.active = TRUE",
      [communityName]
    );

    if (!communityResult.rows.length) {
      return;
    }

    var communityData = communityResult.rows[0];

    if (cachingBool) {
      await redisClient.set(
        `community:${communityName}`,
        JSON.stringify(communityData)
      );
    }
    return communityData;
  } catch (error) {
    console.error("Database error:", error);
    return error;
  }
}

module.exports = { getCommunityData };
