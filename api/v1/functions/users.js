const pool = require("../../db");
const redisClient = require("../../dbredis");
const config = require("../../config/config.json");

const cachingBool = Boolean(config.caching);

async function getUserData(userToken) {
  // Return list of users data based on users token
  try {
    if (cachingBool) {
      redisClient.select(0);

      var value = await redisClient.get(`userData:${userToken}`);

      if (value) {
        // Data found in Redis, parse and send response
        return value;
      }
    }
    // Data not found in Redis, fetch from PostgreSQL
    const userResult = await pool.query(
      // "SELECT user_id FROM users WHERE token = $1",
      "SELECT user_id, username, email, bio, avatar_url, created_at, locality_country, locality_state, locality_city, active from users where users.token = $1",
      [userToken]
    );

    if (!userResult.rows.length) {
      return;
    }

    var userData = userResult.rows[0];

    if (cachingBool) {
      await redisClient.set(`userData:${userToken}`, JSON.stringify(userData));
    }
    return JSON.stringify(userData);
  } catch (error) {
    console.error(error);
    return error;
  }
}

async function getAdminData(adminToken) {
  // Return list of users data based on users token
  try {
    if (cachingBool) {
      redisClient.select(0);

      var value = await redisClient.get(`adminData:${adminToken}`);

      if (value) {
        // Data found in Redis, parse and send response
        return value;
      }
    }
    // Data not found in Redis, fetch from PostgreSQL
    const adminResult = await pool.query(
      // "SELECT user_id FROM users WHERE token = $1",
      "SELECT user_id, username, email, avatar_url, created_at, user_role, active from users where users.token = $1",
      [adminToken]
    );

    if (!adminResult.rows.length) {
      return;
    }

    var adminData = adminResult.rows[0];

    if (cachingBool) {
      await redisClient.set(
        `adminData:${adminToken}`,
        JSON.stringify(adminData)
      );
    }
    return JSON.stringify(adminData);
  } catch (error) {
    console.error(error);
    return error;
  }
}

module.exports = { getUserData, getAdminData };
