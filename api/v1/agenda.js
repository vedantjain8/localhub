const express = require("express");
const router = express.Router();

const pool = require("../db");
const { getUserData } = require("./functions/users");
const redisClient = require("../dbredis");
const { getAdminData } = require("./functions/users");
var validator = require("validator");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);

const getAgenda = async (request, response) => {
  var offset = parseInt(request.query.offset);

  if (!offset) {
    offset = 0;
  }

  try {
    if (cachingBool) {
      redisClient.select(0);
      const value = await redisClient.get(`agenda:offset-${offset}`);
      if (value) {
        return response
          .status(200)
          .json({ status: 200, response: JSON.parse(value) }); // Data found in Redis
      }
    }

    const { rows: agendaData } = await pool.query(
      `SELECT
        agenda_id,
        agenda_title,
        agenda_description,
        image_url,
        locality_city,
        locality_state,
        locality_country,
        agenda_start_date,
        agenda_end_date,
        created_at
      FROM
        agenda
      WHERE
        active = TRUE
      ORDER BY
        agenda_start_date DESC
      LIMIT
        10
      OFFSET
        $1`,
      [offset]
    );

    if (cachingBool) {
      await redisClient.set(
        `agenda:offset-${offset}`,
        JSON.stringify(agendaData)
      );
    }

    return response.status(200).json({ status: 200, response: agendaData });
  } catch (error) {
    console.error(error);
    return response.status(500).json({ status: 500, response: error });
  }
};

const createAgenda = async (request, response) => {
  try {
    const {
      token,
      agenda_title,
      agenda_description,
      locality_city,
      locality_state,
      locality_country,
      agenda_start_date,
      agenda_end_date,
      image_url,
    } = request.body || "";

    if (!token) {
      return response
        .status(400)
        .json({ status: 400, response: "Token is required" });
    }

    if (
      !agenda_title ||
      agenda_title == "" ||
      !validator.isLength(agenda_title, { min: 5, max: 200 })
    ) {
      return response
        .status(400)
        .json({ status: 400, response: "Enter a valid agenda title" });
    }

    if (
      locality_city == null ||
      locality_city == "" ||
      locality_state == null ||
      locality_state == "" ||
      locality_country == null ||
      locality_country == ""
    ) {
      return response
        .status(400)
        .json({ status: 400, response: "Locality fields are required" });
    }

    if (
      !agenda_start_date ||
      !agenda_end_date ||
      !validator.isISO8601(agenda_start_date) ||
      !validator.isISO8601(agenda_end_date)
    ) {
      return response
        .status(400)
        .json({ status: 400, response: "Enter a valid start and end date" });
    }

    if (agenda_start_date > agenda_end_date) {
      return response.status(400).json({
        status: 400,
        response: "Agenda start date cannot be after agenda end date",
      });
    }

    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (!user_id) {
      return response
        .status(401)
        .json({ status: 401, response: "Token is not valid" });
    }

    await pool.query(
      "INSERT INTO agenda (user_id, agenda_title, agenda_description, image_url, locality_city, locality_state, locality_country, agenda_start_date, agenda_end_date) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)",
      [
        user_id,
        agenda_title,
        agenda_description,
        image_url == undefined ? "" : image_url,
        locality_city,
        locality_state,
        locality_country,
        agenda_start_date,
        agenda_end_date,
      ]
    );

    // Clear cache if caching is enabled
    if (cachingBool) {
      const keys = await redisClient.keys("agenda:offset-*");

      // Delete each key
      const deletePromises = keys.map((key) => redisClient.del(key));

      // Wait for all keys to be deleted
      await Promise.all(deletePromises);
    }

    response
      .status(200)
      .json({ status: 200, response: "Agenda created successfully" });
  } catch (error) {
    console.error(error);
    response.status(500).json({ status: 500, response: error });
  }
};

const updateAgenda = async (request, response) => {
  const agenda_id = parseInt(request.params.id);
  const {
    token,
    agenda_title,
    agenda_description,
    image_url,
    locality_city,
    locality_state,
    locality_country,
    agenda_start_date,
    agenda_end_date,
  } = request.body;

  try {
    if (
      agenda_start_date != undefined &&
      agenda_end_date != undefined &&
      agenda_start_date > agenda_end_date
    ) {
      return response.status(400).json({
        status: 400,
        response: "Agenda start date cannot be after event end date",
      });
    }

    // Construct the SET clause dynamically based on provided fields
    const setClause = [];
    const values = [agenda_id];

    if (agenda_title !== undefined) {
      setClause.push(`agenda_title = $${values.push(agenda_title)}`);
    }

    if (agenda_description !== undefined) {
      setClause.push(
        `agenda_description = $${values.push(agenda_description)}`
      );
    }

    if (image_url !== undefined && image_url !== "") {
      setClause.push(`image_url = $${values.push(image_url)}`);
    }

    if (locality_city !== undefined && locality_city !== "") {
      setClause.push(`locality_city = $${values.push(locality_city)}`);
    }

    if (locality_state !== undefined && locality_state !== "") {
      setClause.push(`locality_state = $${values.push(locality_state)}`);
    }

    if (locality_country !== undefined && locality_country !== "") {
      setClause.push(`locality_country = $${values.push(locality_country)}`);
    }

    if (agenda_start_date !== undefined) {
      setClause.push(`agenda_start_date = $${values.push(agenda_start_date)}`);
    }

    if (agenda_end_date !== undefined) {
      setClause.push(`agenda_end_date = $${values.push(agenda_end_date)}`);
    }

    // Check if any valid fields were provided
    if (setClause.length === 0) {
      return response.status(400).json({
        status: 400,
        response: "No valid fields provided for update.",
      });
    }

    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (!user_id) {
      return response
        .status(401)
        .json({ status: 401, response: "Token is not valid" });
    }

    const updateQuery = `UPDATE agenda SET ${setClause.join(
      ", "
    )} WHERE user_id = ${user_id} AND agenda_id = $1 RETURNING agenda_id`;

    pool.query(updateQuery, values, async (error, results) => {
      if (error) {
        console.error(error);
        return response
          .status(500)
          .json({ status: 500, response: error.message });
      }

      if (results.rowCount === 0) {
        return response.status(404).json({
          status: 404,
          response: `Agenda with ID ${agenda_id} not found for the user.`,
        });
      }

      if (cachingBool) {
        // Get all keys matching the pattern 'post:offset-*'
        const keys = await redisClient.keys("agenda:offset-*");

        // Delete each key
        const deletePromises = keys.map((key) => redisClient.del(key));

        // Wait for all keys to be deleted
        await Promise.all(deletePromises);
      }

      response.status(200).json({
        status: 200,
        response: `Agenda modified having agenda_id: ${agenda_id}`,
      });
    });
  } catch (error) {
    console.error(error);
    return response.status(500).json({ status: 500, response: error });
  }
};

const deleteAgenda = async (request, response) => {
  const agenda_id = parseInt(request.params.id);
  const token = request.body.token;

  try {
    if (!agenda_id) {
      return response
        .status(400)
        .json({ status: 400, response: "agenda_id is required" });
    }

    if (!token) {
      return response
        .status(400)
        .json({ status: 400, response: "Provide a user token" });
    }

    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (!user_id) {
      return response
        .status(401)
        .json({ status: 401, response: "Token is not valid" });
    }

    pool.query(
      `UPDATE agenda SET active = false WHERE user_id = $1 AND agenda_id = $2 RETURNING agenda_id`,
      [user_id, agenda_id],
      async (error, result) => {
        if (error) {
          console.error(error);
          return response.status(500).json({ status: 500, response: error });
        }
        userData = result.rows[0];

        if (userData.length == 0) {
          return response
            .status(400)
            .json({ status: 400, response: "No post found" });
        }

        if (cachingBool) {
          const keys = await redisClient.keys("agenda:offset-*");

          // Delete each key
          const deletePromises = keys.map((key) => redisClient.del(key));

          // Wait for all keys to be deleted
          await Promise.all(deletePromises);
        }
        return response.status(200).json({
          status: 200,
          response: `agenda deleted for agenda id: ${userData.agenda_id}`,
        });
      }
    );
  } catch (error) {
    console.error(error);
    return response.status(400).json({ status: 400, response: error.message });
  }
};

router.get("/agendas", getAgenda);
router.post("/agendas/create", createAgenda);
router.put("/agendas/:id", updateAgenda);
router.delete("/agendas/:id", deleteAgenda);

module.exports = router;
