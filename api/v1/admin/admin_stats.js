const express = require("express");
const router = express.Router();

const moment = require("moment-timezone");
const pool = require("../../db");
const redisClient = require("../../dbredis");
var validator = require("validator");
const { getAdminData } = require("../functions/users");
const { adminLog } = require("./functions/adminLog");
const checkPassword = require("../functions/hash_password");

const localhubStatsAdmin = async (request, response) => {
  const token = request.body.token;
  var responseData = {};

  if (!token) {
    return response
      .status(400)
      .json({ status: 400, response: "Token cannot be null" });
  }

  try {
    const admin_data = JSON.parse(await getAdminData(token));

    if (admin_data.user_role !== 2) {
      return response
        .status(401)
        .json({ status: 401, response: "User is not an admin" });
    }

    const [
      user,
      community,
      popularCommuntiy,
      post,
      popularPost,
      adminLog,
      reportPost,
      reportComment,
    ] = await Promise.all([
      // user stats
      pool.query(`
          SELECT
            COUNT(user_id) FILTER (WHERE user_role = 0) AS total_public_users,
            COUNT(user_id) FILTER (WHERE user_role = 1) AS total_moderators,
            COUNT(user_id) FILTER (WHERE user_role = 2) AS total_admins,
            COUNT(user_id) FILTER (WHERE active = 'T') AS active_users,
            COUNT(user_id) AS total_users
          FROM
            users
        `),

      // community
      pool.query(`
        SELECT
        COUNT(community.community_id) FILTER (WHERE active=true) AS total_active_communities,
        COUNT(community.community_id) AS total_communities
        FROM
        community_stats
        JOIN community on community.community_id = community_stats.community_id
        `),

      // popular community
      pool.query(
        `SELECT
        community.community_id,
        community.community_name,
        community.creator_user_id,
        community.active,
        community_stats.subscriber_count
      FROM
        community_stats
        JOIN community ON community.community_id = community_stats.community_id
      ORDER BY
        subscriber_count desc
      LIMIT
        5`
      ),

      // post stats
      pool.query(`
      SELECT
      COUNT(post_id) FILTER (
        WHERE
          active = TRUE
      ) AS total_active_posts,
      COUNT(post_id) AS total_posts
      FROM
        posts
          `),

      // most popular posts
      pool.query(
        `SELECT
        posts.post_id,
        posts.post_title,
        posts_stats.total_views,
        posts_stats.total_comments,
        posts_stats.total_votes
      FROM
        posts_stats
        JOIN posts ON posts.post_id = posts_stats.post_id
      ORDER BY
        total_views desc
      LIMIT
        5`
      ),

      // admin logs
      pool.query(
        `SELECT
        logEvent,
        logDescription,
        created_at,
        log_id
      FROM
        adminLog
      ORDER BY
        created_at desc
      LIMIT
        10;`
      ),

      // report logs
      pool.query(
        `SELECT
        post_id,
        report_time,
        user_id
      FROM
        report_posts
      ORDER BY
        report_time desc
      LIMIT
        10`
      ),

      pool.query(
        `SELECT
        comment_id,
        user_id,
        report_time
      FROM
        report_comment
      ORDER BY
        report_time desc
      LIMIT
        10`
      ),
    ]);

    responseData["user"] = user.rows[0];
    responseData["community"] = community.rows;
    responseData["popularCommuntiy"] = popularCommuntiy.rows;
    responseData["post"] = post.rows[0];
    responseData["popularPost"] = popularPost.rows;
    responseData["adminLog"] = adminLog.rows;
    responseData["reportPost"] = reportPost.rows;
    responseData["reportComment"] = reportComment.rows;

    return response.status(200).json({ status: 200, response: responseData });
  } catch (error) {
    console.error(error);
    return response.status(500).json({ status: 500, response: error.message });
  }
};

router.post("/stats", localhubStatsAdmin);

module.exports = router;
