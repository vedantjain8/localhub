const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
const { getAdminData } = require("./functions/users");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);

const agenda = async (request, response) => {
  try {
    const {
      token,
      event_title,
      event_description,
      image_url,
      locality_city,
      locality_state,
      locality_country,
      event_start_date,
      event_end_date,
    } = request.body || "";

    // todo add validation

    const admin_data = JSON.parse((await getAdminData(token)) ?? null);

    if (admin_data == null) {
      return response
        .status(401)
        .json({ status: 401, response: "Token is not valid" });
    }

    if (admin_data.user_role !== 2 && admin_data.user_role !== 1) {
      return response
        .status(401)
        .json({ status: 401, response: "Unauthorised" });
    }

    await pool.query(
      "INSERT INTO agenda (user_id, event_title, event_description, image_url, locality_city, locality_state, locality_country, event_start_date, event_end_date) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)",
      [
        admin_data.user_id,
        event_title,
        event_description,
        image_url,
        locality_city,
        locality_state,
        locality_country,
        event_start_date,
        event_end_date,
      ]
    );

    // Clear cache if caching is enabled
    if (cachingBool) {
      await redisClient.del("events");
    }

    response
      .status(200)
      .json({ status: 200, response: "Event created successfully" });
  } catch (error) {
    console.error(error);
    response
      .status(500)
      .json({ status: 500, response: "Internal server error" });
  }
};

router.post("/agenda/create", agenda);

module.exports = router;
