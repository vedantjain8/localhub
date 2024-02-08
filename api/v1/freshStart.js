const express = require("express");
const pool = require("../db");
const redisClient = require("../dbredis");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);
const envRootPassword = String(config.rootPassword);

const router = express.Router();

const clearAllComments = async (request, response) => {
  const rootPassword = request.body.rootPassword;
  if (rootPassword == envRootPassword) {
    try {
      if (cachingBool) {
        redisClient.sendCommand(["flushall"]);
      }
      await pool.query(`DELETE FROM report_comment`);
      await pool.query("UPDATE posts_stats SET total_comments = 0 WHERE total_comments != 0");
      await pool.query(`DELETE FROM posts_comments_link`);

      return response.status(200).json({ status: "Done" });
    } catch (error) {
      console.error("Database error:", error);
      throw new Error(error.message);
    }
  } else {
    return response.status(401).json({ error: "Not authorised" });
  }
};

const clearAllVotes = async (request, response) => {
  const rootPassword = request.body.rootPassword;
  if (rootPassword == envRootPassword) {
    try {
      if (cachingBool) {
        redisClient.sendCommand(["flushall"]);
      }
      await pool.query("UPDATE posts_stats SET total_votes = 0 WHERE total_votes != 0");
      await pool.query(`DELETE FROM posts_vote_link`);

      return response.status(200).json({ status: "Done" });
    } catch (error) {
      console.error("Database error:", error);
      throw new Error(error.message);
    }
  } else {
    return response.status(401).json({ error: "Not authorised" });
  }
};

const clearAll = async (request, response) => {
  const rootPassword = request.body.rootPassword;
  if (rootPassword == envRootPassword) {
    try {
      if (cachingBool) {
        redisClient.sendCommand(["flushall"]);
      }
      await pool.query(`DELETE FROM report_comment`);
      await pool.query(`DELETE FROM report_posts`);
      await pool.query(`DELETE FROM posts_comments_link`);
      await pool.query(`DELETE FROM posts_vote_link`);
      await pool.query(`DELETE FROM posts_stats`);
      await pool.query(`DELETE FROM posts`);
      await pool.query(`DELETE FROM community_stats`);
      await pool.query(`DELETE FROM users_community_link`);
      await pool.query(`DELETE FROM community`);
      await pool.query(`DELETE FROM users`);

      return response.status(200).json({ status: "Done" });
    } catch (error) {
      console.error("Database error:", error);
      throw new Error(error.message);
    }
  } else {
    return response.status(401).json({ error: "Not authorised" });
  }
};

router.post("/clear/comments/all", clearAllComments);
router.post("/clear/votes/all", clearAllVotes);
router.post("/clear/all", clearAll);

module.exports = router;
