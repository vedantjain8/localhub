const express = require("express");
const pool = require("../db");
const router = express.Router();

const createVote = async (request, response, vote_type) => {
  try {
    const { token } = request.body;
    const post_id = parseInt(request.params.id);

    if (!token || !post_id || !vote_type) {
      return response.status(400).json({ error: "Invalid input data" });
    }

    const user_id = JSON.parse(await getUserData(token))["user_id"];

    const existingVote = await pool.query(
      "SELECT * FROM post_vote_link WHERE post_id = $1 AND user_id = $2",
      [post_id, user_id]
    );

    if (existingVote.rows.length > 0) {
      return response
        .status(409)
        .json({ status: "User already voted this post" });
    }

    await pool.query(
      "INSERT INTO post_vote_link (post_id, user_id, vote_type) VALUES ($1, $2, $3)",
      [post_id, user_id, vote_type]
    );

    response.status(200).json({
      message: `Vote submitted for post_id: ${post_id}`,
    });
  } catch (error) {
    console.error("Error in voting post:", error);
    response.status(500).json({ error: "Error voting for post" });
  }
};

router.post("/vote/upvote/posts/:id", (request, response) =>
  createVote(request, response, "U")
);
router.post("/vote/downvote/posts/:id", (request, response) =>
  createVote(request, response, "D")
);
// router.get("/vote/comment/:id", postRoutes.getPostById);

module.exports = router;
