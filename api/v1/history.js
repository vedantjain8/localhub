const express = require("express");
const pool = require("../db");
const redisClient = require("../dbredis");
const config = require("../config/config.json");

const cachingBool = Boolean(config.caching);

const router = express.Router();

function filterQuery(user_id, offset, vote) {
  return `SELECT
  posts.post_id,
  posts.post_title,
  LEFT(posts.post_content, 159) as short_content,
  posts.post_image,
  posts.community_id,
  posts.is_adult,
  posts.created_at,
  community.community_name,
  community.logo_url
FROM
  posts
JOIN
  community ON posts.community_id = community.community_id
JOIN
  post_vote_link ON posts.user_id = post_vote_link.user_id
WHERE
  posts.active = 'T'
  AND post_vote_link.vote_type = '${vote}'
  AND post_vote_link.user_id = ${user_id}
ORDER BY
  post_vote_link.created_at DESC
LIMIT 20  
OFFSET ${offset}`;
}

const history_upvote = async (request, response) => {
  var { offset } = parseInt(request.body.offset);
  const token = request.body.token;
  const vote = "U";

  if (!offset) {
    offset = 0;
  }

  if (!token) {
    return response.status(400).json({ error: "Provide a user token" });
  }

  const user_id = JSON.parse(await getUserData(token))["user_id"];

  try {
    if (cachingBool) {
      const value = await redisClient.get(
        `user${user_id}:voteType${vote}:${offset}`
      );
      return response.status(200).json(value);
    }

    pool.query(filterQuery(user_id, offset, vote), (error, results) => {
      if (error) {
        response.status(400).json({ error: error });
      }

      const userData = results.rows;

      if (cachingBool) {
        redisClient.set(
          `user${user_id}:voteType${vote}:${offset}`,
          JSON.stringify(userData)
        );
      }
      return response.status(200).json(userData);
    });
  } catch (e) {
    return response.status(400).json({ error: e });
  }
};

const history_downvote = async (request, response) => {
  var { offset } = parseInt(request.body.offset);
  const token = request.body.token;
  const vote = "D";

  if (!offset) {
    offset = 0;
  }

  if (!token) {
    return response.status(400).json({ error: "Provide a user token" });
  }

  const user_id = JSON.parse(await getUserData(token))["user_id"];

  try {
    if (cachingBool) {
      const value = await redisClient.get(
        `user${user_id}:voteType${vote}:${offset}`
      );
      return response.status(200).json(value);
    }

    pool.query(filterQuery(user_id, offset, vote), (error, results) => {
      if (error) {
        response.status(400).json({ error: error });
      }

      const userData = results.rows;

      if (cachingBool) {
        redisClient.set(
          `user${user_id}:voteType${vote}:${offset}`,
          JSON.stringify(userData)
        );
      }
      return response.status(200).json(userData);
    });
  } catch (e) {
    return response.status(400).json({ error: e });
  }
};

router.post("/history/upvote", history_upvote);
router.post("/history/downvote", history_downvote);

module.exports = router;
