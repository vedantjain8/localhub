const pool = require("../../../db");

async function adminLogData(logEvent, logDescription, user_id) {
  try {
    await pool.query(
      "INSERT INTO admin_log (user_id, logEvent, logDescription) VALUES ($1, $2, $3)",
      [user_id, logEvent, logDescription]
    );
    return;
  } catch (error) {
    console.error(error);
    return error;
  }
}

module.exports = { adminLogData };
