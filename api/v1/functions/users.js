const pool = require("../../db");
const redisClient = require("../../dbredis");
const config = require("../../config/config.json");

const cachingBool = Boolean(config.caching);

async function getUserId(token) {
  // Check if the user exists and get the user_id
  try {
    if (cachingBool) {
      redisClient.select(0);

      value = await redisClient.get(`id-${token}`);

      if (value) {
        // Data found in Redis, parse and send response
        return value;
      }
    } else {
      // Data not found in Redis, fetch from PostgreSQL
      const userResult = await pool.query(
        "SELECT user_id FROM users WHERE token = $1",
        [token]
      );

      if (!userResult.rows.length) {
        return;
      }

      userData = userResult.rows[0].user_id;
      // Store data in Redis with expiration (e.g., 1 hour)
      if (cachingBool) {
        redisClient.setEx(`id-${token}`, 3600, JSON.stringify(userData));
      }
      return userData;
    }
  } catch (error) {
    console.error("Database error:", error);
    return error;
  }
}

module.exports = { getUserId };
