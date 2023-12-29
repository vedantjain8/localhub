const express = require("express");
const router = express.Router();

const pool = require("../db");

const reportComment = async (request, response) => {
  try {
    const { token, commentID } = request.body;

    if (!token) {
      return response.status(400).json({ error: "token is required" });
    }
    if (!commentID) {
      return response.status(400).json({ error: "commentID is required" });
    }

    // Check if the user exists and get the user_id
    const user_id = JSON.parse(await getUserData(token))["user_id"];

    pool.query(
      "INSERT INTO report_comment (user_id, comment_id) VALUES ($1, $2)",
      [user_id, commentID],
      (error, results) => {
        if (error) {
          if (error.code === "23505") {
            // Unique violation error, the record already exists
            response
              .status(409)
              .json({ status: "User already reported this comment" });
          } else {
            // Other error
            response.status(400).json({ status: "Error in reporting" });
          }
        } else {
          // Successfully inserted
          return response
            .status(200)
            .json({ status: "Successfully reported comment" });
        }
      }
    );
  } catch (error) {
    console.error("Error reporting comment with error:", error);
    response.status(500).json({ error: "Error reporting comment" });
  }
};

const reportPost = async (request, response) => {
  try {
    const { token, postID } = request.body;

    if (!token) {
      return response.status(400).json({ error: "token is required" });
    }
    if (!postID) {
      return response.status(400).json({ error: "postID is required" });
    }

    // Check if the user exists and get the user_id
    const user_id = JSON.parse(await getUserData(token))["user_id"];

    pool.query(
      "INSERT INTO report_post (user_id, post_id) VALUES ($1, $2)",
      [user_id, postID],
      (error, results) => {
        if (error) {
          if (error.code === "23505") {
            // Unique violation error, the record already exists
            response
              .status(409)
              .json({ status: "User already reported this post" });
          } else {
            // Other error
            response.status(400).json({ status: "Error in reporting" });
          }
        } else {
          // Successfully inserted
          return response.status(200).json({ status: "Successfully reported post" });
        }
      }
    );
  } catch (error) {
    console.error("Error reporting post with error:", error);
    response.status(500).json({ error: "Error reporting post" });
  }
};

router.post("/report/comment", reportComment);
router.post("/report/post", reportPost);


module.exports = router;
