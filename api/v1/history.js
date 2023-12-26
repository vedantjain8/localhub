const express = require("express");
const pool = require("../db");

const router = express.Router();

const history_upvote = async (request, response) => {
  var { offset } = parseInt(request.body.offset);
  var token = request.body.token;

  if (!offset) {
    offset = 0;
  }

  if (!token) {
    return response.status(400).json({ error: "Provide a user token" });
  }

  const userResult = await pool.query(
    "SELECT user_id FROM users WHERE token = $1",
    [token]
  );

  if (!userResult.rows.length) {
    return response.status(400).json({
      error: "Not a valid token",
    });
  }

  const user_id = userResult.rows[0].user_id;

  try {
    pool.query(
      `SELECT
      posts.post_id,
      posts.post_title,
      CONCAT(SUBSTRING(posts.post_content, 1, 159), '...') as short_content,
      posts.image,
      posts.subreddit_id,
      posts.created_at,
      posts.total_votes,
      posts.total_comments,
      posts.total_views,
      subreddit.subreddit_name,
      subreddit.logo_url
  FROM
      posts
  JOIN
      subreddit ON posts.subreddit_id = subreddit.subreddit_id
  JOIN
      post_vote_link ON posts.post_id = post_vote_link.post_id
  WHERE
      posts.active = 'T'
      AND post_vote_link.vote_type = 'U'
      AND post_vote_link.user_id = $1
  ORDER BY
      post_vote_link.created_at DESC
  LIMIT 20  
  OFFSET $2`,
      [user_id, offset],
      (error, results) => {
        if (error) {
          response.status(400).json({ error: error });
        }
        response.status(200).json(results.rows);
      }
    );
  } catch (e) {
    return response.status(400).json({ error: e });
  }
};

const history_downvote = async (request, response) => {
  var { offset } = parseInt(request.body.offset);
  var token = request.body.token;

  if (!offset) {
    offset = 0;
  }

  if (!token) {
    return response.status(400).json({ error: "Provide a user token" });
  }

  const userResult = await pool.query(
    "SELECT user_id FROM users WHERE token = $1",
    [token]
  );

  if (!userResult.rows.length) {
    return response.status(400).json({
      error: "Not a valid token",
    });
  }

  const user_id = userResult.rows[0].user_id;

  try {
    pool.query(
      `SELECT
      posts.post_id,
      posts.post_title,
      CONCAT(SUBSTRING(posts.post_content, 1, 159), '...') as short_content,
      posts.image,
      posts.subreddit_id,
      posts.created_at,
      posts.total_votes,
      posts.total_comments,
      posts.total_views,
      subreddit.subreddit_name,
      subreddit.logo_url
  FROM
      posts
  JOIN
      subreddit ON posts.subreddit_id = subreddit.subreddit_id
  JOIN
      post_vote_link ON posts.post_id = post_vote_link.post_id
  WHERE
      posts.active = 'T'
      AND post_vote_link.vote_type = 'D'
      AND post_vote_link.user_id = $1
  ORDER BY
      post_vote_link.created_at DESC
  LIMIT 20  
  OFFSET $2`,
      [user_id, offset],
      (error, results) => {
        if (error) {
          response.status(400).json({ error: error });
        }
        response.status(200).json(results.rows);
      }
    );
  } catch (e) {
    return response.status(400).json({ error: e });
  }
};

router.post("/history/upvote", history_upvote);
router.post("/history/downvote", history_downvote);

module.exports = router;
