const express = require("express");
const pool = require("../db");
const config = require("../config/config.json");

const router = express.Router();

const hello = (request, response) => {
  response.status(200).send("hello");
};

router.get("/", hello)

module.exports = router
