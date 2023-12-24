const { Pool } = require("pg");
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
});

module.exports = pool;
