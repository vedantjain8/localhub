const express = require("express");
const redisClient = require("../dbredis");
const config = require("../config/config.json");
var cron = require("node-cron");
const { getUserData } = require("./functions/users");

const cachingBool = Boolean(config.caching);
const router = express.Router();

const pool = require("../db");

const reportComment = async (request, response) => {
  try {
    const { token, comment_id } = request.body;

    if (!token) {
      return response.status(400).json({ error: "token is required" });
    }
    if (!comment_id) {
      return response.status(400).json({ error: "commentID is required" });
    }

    // Check if the user exists and get the user_id
    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (cachingBool) {
      await redisClient.hSet(
        "report_comment_data",
        `comment:${comment_id}`,
        JSON.stringify({
          userId: user_id,
          comment_id: comment_id,
          report_time: new Date().toISOString(),
        })
      );
    } else {
      pool.query(
        "INSERT INTO report_comment (user_id, comment_id) VALUES ($1, $2)",
        [user_id, comment_id],
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
          }
        }
      );
    }
    return response
      .status(200)
      .json({ status: "Successfully reported comment" });
  } catch (error) {
    console.error("Error reporting comment with error:", error);
    response.status(500).json({ error: "Error reporting comment" });
  }
};

const reportPost = async (request, response) => {
  try {
    const { token, post_id } = request.body;

    if (!token) {
      return response.status(400).json({ error: "token is required" });
    }
    if (!post_id) {
      return response.status(400).json({ error: "post_id is required" });
    }

    // Check if the user exists and get the user_id
    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (cachingBool) {
      await redisClient.hSet(
        "report_post_data",
        `post:${post_id}`,
        JSON.stringify({
          userId: user_id,
          post_id: post_id,
          report_time: new Date().toISOString(),
        })
      );
    } else {
      pool.query(
        "INSERT INTO report_posts (user_id, post_id) VALUES ($1, $2)",
        [user_id, post_id],
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
          }
        }
      );
    }
    return response.status(200).json({ status: "Successfully reported post" });
  } catch (error) {
    console.error("Error reporting post with error:", error);
    response.status(500).json({ error: "Error reporting post" });
  }
};

router.post("/report/comment", reportComment);
router.post("/report/post", reportPost);

cron.schedule("*/30 * * * *", async () => {
  if (cachingBool) {
    console.log("report cron running");

    // comments
    const commentReport = await redisClient.hGetAll(
      "report_comment_data",
      "comment:*"
    );

    for (const commentReportData in commentReport) {
      const data = JSON.parse(commentReport[commentReportData]);

      await pool.query(
        "INSERT INTO report_comment (user_id, comment_id, report_time) VALUES ($1, $2, $3)",
        [data.userId, data.comment_id, data.report_time],
        async (error, results) => {
          if (error) {
            if (error.code === "23505") {
              // Unique violation error, the record already exists
              return;
            } else {
              // Other error
              console.log("report cron error", error);
              return;
            }
          }
          await redisClient.hDel(
            "report_comment_data",
            `comment:${data.comment_id}`
          );
        }
      );
    }

    // posts
    const postReport = await redisClient.hGetAll("report_post_data", "post:*");

    for (const ReportData in postReport) {
      const data = JSON.parse(postReport[ReportData]);

      await pool.query(
        "INSERT INTO report_posts (user_id, post_id, report_time) VALUES ($1, $2, $3)",
        [data.userId, data.post_id, data.report_time],
        async (error, results) => {
          if (error) {
            if (error.code === "23505") {
              // Unique violation error, the record already exists
              return;
            } else {
              // Other error
              console.log("report cron error", error);
              return;
            }
          }

          await redisClient.hDel("report_post_data", `post:${data.post_id}`);
        }
      );
    }
  }
});

module.exports = router;
