const express = require("express");
const pool = require("../db");
const redisClient = require("../dbredis");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);

const router = express.Router();

const meInfo = async (request, response) => {
  const userToken = request.body.token;

  try {
    if (cachingBool) {
      redisClient.select(0);
      // Check if data is available in Redis
      var value = await redisClient.get(`userData-${userToken}`);

      if (value) {
        // Data found in Redis, parse and send response
        return response.status(200).json(JSON.parse(value));
      }
    }
    // Data not found in Redis, fetch from PostgreSQL
    const userResult = await pool.query(
      "SELECT user_id, username, email, bio, avatar_url, created_at, locality_country, locality_state, locality_city from users where users.token = $1",
      [userToken]
    );

    if (!userResult.rows.length) {
      return;
    }

    var userData = userResult.rows[0];

    if (cachingBool) {
      await redisClient.set(`userData-${userToken}`, JSON.stringify(userData));
    }
    return response.status(200).json(JSON.parse(userData));
  } catch (error) {
    console.error("Database error:", error);
    response.status(400).json({ error: error.message });
  }
};

router.post("/me", meInfo);

module.exports = router;
