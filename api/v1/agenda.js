const express = require("express");
const router = express.Router();

const pool = require("../db");
const redisClient = require("../dbredis");
const { getAdminData } = require("./functions/users");
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
      image_url,
      locality_city,
      locality_state,
      locality_country,
      agenda_start_date,
      agenda_end_date,
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

    if (agenda_start_date > agenda_end_date) {
      return response.status(400).json({
        status: 400,
        response: "Agenda start date cannot be after agenda end date",
      });
    }

    await pool.query(
      "INSERT INTO agenda (user_id, agenda_title, agenda_description, image_url, locality_city, locality_state, locality_country, agenda_start_date, agenda_end_date) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)",
      [
        admin_data.user_id,
        agenda_title,
        agenda_description,
        image_url,
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
      setClause.push(`agenda_title = $${values.push(post_title)}`);
    }

    if (agenda_description !== undefined) {
      setClause.push(`agenda_description = $${values.push(post_content)}`);
    }

    if (image_url !== undefined && post_image !== "") {
      setClause.push(`image_url = $${values.push(post_image)}`);
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

router.get("/agendas", getAgenda);
router.post("/agendas/create", createAgenda);
router.put("/agendas/", updateAgenda);

module.exports = router;
