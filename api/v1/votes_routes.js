const express = require("express");
const pool = require("../db");
const redisClient = require("../dbredis");
const config = require("../config/config.json");
var cron = require("node-cron");
const { getUserData } = require("./functions/users");

const cachingBool = Boolean(config.caching);

const router = express.Router();

const createVote = async (request, response, vote_type) => {
  try {
    const { token } = request.body;
    const post_id = parseInt(request.params.id);

    if (!token || !post_id || !vote_type) {
      return response
        .status(400)
        .json({ status: 400, response: "Invalid input data" });
    }

    const userDataString = await getUserData(token);
    const user_id = await JSON.parse(userDataString)["user_id"];
    // const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (cachingBool) {
      const voteDataValue = await redisClient.hGet(
        "user_vote_data",
        `user:${user_id}:post:${post_id}`
      );

      if (voteDataValue) {
        return response
          .status(409)
          .json({ status: 409, response: "User already voted this post" });
      }
    }
    const existingVote = await pool.query(
      "SELECT * FROM posts_vote_link WHERE post_id = $1 AND user_id = $2",
      [post_id, user_id]
    );

    if (existingVote.rows.length > 0) {
      return response
        .status(409)
        .json({ status: 409, response: "User already voted this post" });
    }

    if (cachingBool) {
      // fetch posts for updating values
      const postStats = await redisClient.hGet(
        "post_stats_data",
        `post:stats:${post_id}`
      );

      if (postStats) {
        const postStatsObject = JSON.parse(postStats);
        postStatsObject["total_votes"] += vote_type === "U" ? 1 : -1;

        // update the vote count in the cache
        await redisClient.hSet(
          "post_stats_data",
          `post:stats:${post_id}`,
          JSON.stringify(postStatsObject)
        );

        // Store user-vote link relations in Redis
        await redisClient.hSet(
          "user_vote_data",
          `user:${user_id}:post:${post_id}`,
          JSON.stringify({
            userId: user_id,
            postId: post_id,
            voteType: vote_type,
            created_at: new Date().toISOString(),
          })
        );
      }
    } else {
      await pool.query(
        "INSERT INTO posts_vote_link (post_id, user_id, vote_type) VALUES ($1, $2, $3)",
        [post_id, user_id, vote_type]
      );

      await pool.query(
        "UPDATE posts_stats SET total_votes = total_votes + $2 WHERE post_id = $1",
        [post_id, vote_type === "U" ? 1 : -1]
      );
    }

    return response.status(200).json({
      status: 200,
      response: `Vote submitted for post_id: ${post_id}`,
    });
  } catch (error) {
    console.error(error);
    response
      .status(500)
      .json({ status: 500, response: "Error voting for post" });
  }
};

router.post("/posts/vote/upvote/:id", (request, response) =>
  createVote(request, response, "U")
);

router.post("/posts/vote/downvote/:id", (request, response) =>
  createVote(request, response, "D")
);

// cron job to sync post stats and vote link with redis and db
cron.schedule("*/10 * * * *", async () => {
  if (cachingBool) {
    console.log("vote cron running");
    const userVoteData = await redisClient.hGetAll(
      "user_vote_data",
      "user:*:post:*"
    );

    for (const userVoteKey in userVoteData) {
      const data = JSON.parse(userVoteData[userVoteKey]);
      const postStatsData = await redisClient.hGet(
        "post_stats_data",
        `post:stats:${data.postId}`
      );

      const jsonPostStatsData = JSON.parse(postStatsData);
      const postId = data.postId;
      const total_votes = jsonPostStatsData.total_votes || 0;
      const total_views = jsonPostStatsData.total_views || 0;
      const total_comments = jsonPostStatsData.total_comments || 0;

      if (total_comments === 0 && total_views === 0 && total_votes === 0) {
        continue; // Skip the iteration if all values are zero
      }

      // TODO: make all this query to run in single batch query
      await Promise.all([
        pool.query(
          "UPDATE posts_stats SET total_votes = $2,total_comments = $3, total_views = $4 WHERE post_id = $1",
          [postId, total_votes, total_comments, total_views]
        ),
        pool.query(
          "INSERT INTO posts_vote_link (post_id, user_id, vote_type, created_at) VALUES ($1, $2, $3, $4)",
          [data.postId, data.userId, data.voteType, data.created_at]
        ),
        redisClient.hDel(
          "user_vote_data",
          `user:${data.userId}:post:${data.postId}`
        ),
      ]);
    }
  }
});
module.exports = router;
