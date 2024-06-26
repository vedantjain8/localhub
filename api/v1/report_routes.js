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
      return response
        .status(400)
        .json({ status: 400, response: "token is required" });
    }
    if (!comment_id) {
      return response
        .status(400)
        .json({ status: 400, response: "commentID is required" });
    }

    // Check if the user exists and get the user_id
    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (!user_id) {
      return response
        .status(401)
        .json({ status: 401, response: "Token is not valid" });
    }

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
              response.status(409).json({
                status: 409,
                response: "User already reported this comment",
              });
            } else {
              // Other error
              console.error(error);
              return response
                .status(400)
                .json({ status: 400, response: "Error in reporting" });
            }
          }
        }
      );
    }
    return response
      .status(200)
      .json({ status: 200, response: "Successfully reported comment" });
  } catch (error) {
    console.error(error);
    return response
      .status(500)
      .json({ status: 500, response: "Error reporting comment" });
  }
};

const reportPost = async (request, response) => {
  try {
    const { token, post_id } = request.body;

    if (!token) {
      return response
        .status(400)
        .json({ status: 400, response: "token is required" });
    }
    if (!post_id) {
      return response
        .status(400)
        .json({ status: 400, response: "post_id is required" });
    }

    // Check if the user exists and get the user_id
    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (!user_id) {
      return response
        .status(401)
        .json({ status: 401, response: "Token is not valid" });
    }

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
              response.status(409).json({
                status: 409,
                response: "User already reported this post",
              });
            } else {
              // Other error
              console.error(error);
              return response
                .status(400)
                .json({ status: 400, response: "Error in reporting" });
            }
          }
        }
      );
    }
    return response
      .status(200)
      .json({ status: 200, response: "Successfully reported post" });
  } catch (error) {
    console.error(error);
    return response.status(500).json({ status: 500, response: error });
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
              console.error(error);
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
              console.error(error);
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
