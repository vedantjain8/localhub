const pool = require("../../../db");

async function adminLogData(logEvent, logDescription, user_id) {
  try {
    await pool.query(
      "INSERT INTO adminlog (user_id, log_event, log_description) VALUES ($1, $2, $3)",
      [user_id, logEvent, logDescription]
    );
    return;
  } catch (error) {
    console.error(error);
    return error;
  }
}

module.exports = { adminLogData };
