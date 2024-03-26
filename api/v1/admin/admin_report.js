const express = require("express");
const router = express.Router();

const moment = require("moment-timezone");
const pool = require("../../db");
const redisClient = require("../../dbredis");
var validator = require("validator");
const { reservedKeywordsFile } = require("../../tools");
const { getUserData, getAdminData } = require("../functions/users");
const { getCommunityData } = require("../functions/community");
const config = require("../../config/config.json");
var cron = require("node-cron");
const { hashPassword, checkPassword } = require("../functions/hash_password");
const { checkJoinedCommunity } = require("../functions/joinCommunityCheck");
const { adminLogger } = require("./functions/adminLogger");
const cachingBool = Boolean(config.caching);

const allowedCharactersRegex = /^[a-zA-Z0-9_]*$/;

// todo delete community for admin and creator user_id in normal ui
const deleteCommunityAdmin = async (request, response) => {
  const { token, community_id, log_description } = request.body ?? null;

  if (community_id == null) {
    return response.status(400).json({
      status: 400,
      response: "community_id can not be null",
    });
  }

  if (!token || token == null || token == "" || token == undefined) {
    return response
      .status(400)
      .json({ status: 400, response: "token can not be null" });
  }

  const admin_data = JSON.parse((await getAdminData(token)) ?? null);

  if (admin_data == null) {
    return response
      .status(401)
      .json({ status: 401, response: "Token is not valid" });
  }

  if (admin_data["user_role"] != 1) {
    return response
      .status(401)
      .json({ status: 401, response: "User is not an admin" });
  }

  await pool.query(
    "UPDATE community SET active = CASE WHEN active = true THEN false ELSE true END WHERE community_id = $1 returning active",
    [community_id],
    async (error, result) => {
      if (error) {
        console.error(error);
        return response.status(500).json({ status: 500, response: error });
      }

      adminLogger(
        "admin-community-active-toggle",
        `Community with communityID: ${community_id} is now active=${result.rows[0].active}. Log description: ${log_description}`,
        admin_data["user_id"]
      );

      // TODO: implement redis delete community
      // redisClient.del(`:${new_admin_token}`);
      if (cachingBool) {
        await redisClient.flushall();
      }

      return response.status(200).json({
        status: 200,
        response: `Community with communityID: ${community_id} is now active=${result.rows[0].active}`,
      });
    }
  );
};

const deletePostAdmin = async (request, response) => {
  const { token, post_id, log_description } = request.body ?? null;

  if (post_id == null) {
    return response.status(400).json({
      status: 400,
      response: "post_id can not be null",
    });
  }

  if (!token || token == null || token == "" || token == undefined) {
    return response
      .status(400)
      .json({ status: 400, response: "token can not be null" });
  }

  const admin_data = JSON.parse((await getAdminData(token)) ?? null);

  if (admin_data == null) {
    return response
      .status(401)
      .json({ status: 401, response: "Token is not valid" });
  }

  if (admin_data["user_role"] != 1) {
    return response
      .status(401)
      .json({ status: 401, response: "User is not an admin" });
  }

  await pool.query(
    "UPDATE posts SET active = CASE WHEN active = true THEN false ELSE true END WHERE post_id = $1 returning active",
    [post_id],
    (error, result) => {
      if (error) {
        console.error(error);
        return response.status(500).json({ status: 500, response: error });
      }

      // adminLogger(
      //   "admin-post-active-toggle",
      //   `Post with postID: ${post_id} is now active=${result.rows[0].active}`,
      //   admin_data["user_id"]
      // );

      // TODO: implement redis delete posts
      // redisClient.del(`:${new_admin_token}`);

      return response.status(200).json({
        status: 200,
        response: `Post with postID: ${post_id} is now active=${result.rows[0].active}`,
      });
    }
  );
};

const deleteCommentAdmin = async (request, response) => {
  const { token, comment_id, log_description } = request.body ?? null;

  if (comment_id == null) {
    return response.status(400).json({
      status: 400,
      response: "comment_id can not be null",
    });
  }

  if (!token || token == null || token == "" || token == undefined) {
    return response
      .status(400)
      .json({ status: 400, response: "token can not be null" });
  }

  const admin_data = JSON.parse((await getAdminData(token)) ?? null);

  if (admin_data == null) {
    return response
      .status(401)
      .json({ status: 401, response: "Token is not valid" });
  }

  if (admin_data["user_role"] != 1) {
    return response
      .status(401)
      .json({ status: 401, response: "User is not an admin" });
  }

  await pool.query(
    "UPDATE posts_comments_link SET active = CASE WHEN active = true THEN false ELSE true END WHERE comment_id = $1 returning active",
    [comment_id],
    (error, result) => {
      if (error) {
        console.error(error);
        return response.status(500).json({ status: 500, response: error });
      }

      // adminLogger(
      //   "admin-comment-active-toggle",
      //   `Comment with comment_id: ${comment_id} is now active=${result.rows[0].active}`,
      //   admin_data["user_id"]
      // );

      // TODO: implement redis delete posts
      // redisClient.del(`:${new_admin_token}`);

      return response.status(200).json({
        status: 200,
        response: `Comment with commentID: ${comment_id} is now active=${result.rows[0].active}`,
      });
    }
  );
};

const listReportedPosts = async (request, response) => {
  try {
    const { token } = request.body ?? null;
    var offset = parseInt(request.query.offset);

    if (!offset) {
      offset = 0;
    }

    if (!token || token == null || token == "" || token == undefined) {
      return response
        .status(400)
        .json({ status: 400, response: "token can not be null" });
    }

    await pool.query(
      `SELECT report_posts.report_id, report_posts.post_id, report_posts.report_time, posts.post_title, posts.active
      FROM report_posts
      JOIN posts ON report_posts.post_id = posts.post_id
      LIMIT 10 OFFSET $1`,
      [offset],
      (error, result) => {
      if (error) {
        console.error(error);
        return response.status(500).json({ status: 500, response: error });
      }
      return response.status(200).json({
        status: 200,
        response: result.rows,
      });
      }
    );
  } catch (error) {
    console.error(error);
    return response.status(500).json({ status: 500, response: error });
  }
};
const listReportedComments = async (request, response) => {
  try {
    const { token } = request.body ?? null;
    var offset = parseInt(request.query.offset);

    if (!offset) {
      offset = 0;
    }

    if (!token || token == null || token == "" || token == undefined) {
      return response
        .status(400)
        .json({ status: 400, response: "token can not be null" });
    }

    await pool.query(
      `SELECT report_comment.report_id, report_comment.comment_id, report_comment.report_time, posts_comments_link.comment_content, posts_comments_link.active, posts_comments_link.post_id
      FROM report_comment
      JOIN posts_comments_link ON report_comment.comment_id = posts_comments_link.comment_id
      LIMIT 10 OFFSET $1`,
      [offset],
      (error, result) => {
        if (error) {
          console.error(error);
          return response.status(500).json({ status: 500, response: error });
        }
        return response.status(200).json({
          status: 200,
          response: result.rows,
        });
      }
    );
  } catch (error) {
    console.error(error);
    return response.status(500).json({ status: 500, response: error });
  }
};

router.delete("/community/:id", deleteCommunityAdmin);
router.delete("/posts/:id", deletePostAdmin);
router.delete("/comments/:id", deleteCommentAdmin);

router.post("/comments/list", listReportedComments);
router.post("/posts/list", listReportedPosts);

module.exports = router;
