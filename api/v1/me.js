const express = require("express");
const pool = require("../db");
const redisClient = require("../dbredis");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);

const router = express.Router();

const meInfo = async (request, response) => {
  const token = request.body.token;

  try {
    if (cachingBool) {
      redisClient.select(0);
      // Check if data is available in Redis
      value = await redisClient.get(token);

      if (value) {
        // Data found in Redis, parse and send response
        response.status(200).json(JSON.parse(value));
        return;
      }
    } 
      // Data not found in Redis, fetch from PostgreSQL
      const queryResult = await pool.query(
        "SELECT username, email, bio, avatar_url, created_at, karma from users where users.token = $1 and users.active = true",
        [token]
      );

      const userData = queryResult.rows[0];

      // Store data in Redis with expiration (e.g., 1 hour)
      if (cachingBool) {
        redisClient.setEx(token, 3600, JSON.stringify(userData));
      
      response.status(200).json(userData);
      return;
    }
  } catch (error) {
    console.error("Database error:", error);
    response.status(400).json({ error: error.message });
  }
};

router.post("/me", meInfo);

module.exports = router;
