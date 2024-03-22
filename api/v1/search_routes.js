const express = require("express");
const router = express.Router();
const pool = require("../db");

const search = async (request, response) => {
  const searchData = request.query.searchData;

  try {
    const communityQuery = await pool.query(
      "SELECT * FROM community WHERE LOWER(community_name) LIKE LOWER($1 || '%') AND active = 'T' ORDER BY community_id ASC LIMIT 8",
      [searchData]
    );

    const postDataQuery = await pool.query(
      `SELECT
        posts.post_id,
        posts.post_title,
        posts.post_image,
        posts.created_at,
        community.community_name,
        community.logo_url
        FROM
        posts
        JOIN
        community ON posts.community_id = community.community_id
        WHERE
        posts.active = 'T' AND LOWER(posts.post_title) LIKE LOWER('%${searchData}%')
        ORDER BY
        posts.created_at DESC
        LIMIT 8
        OFFSET 0`
    );

    const communityData = communityQuery.rows;
    const postData = postDataQuery.rows;

    return response.status(200).json({
      status: 200,
      response: { communityData, postData },
    });
  } catch (error) {
    console.error(error);
    return response.status(500).json({ status: 500, response: error.message });
  }
};

const communitySearch = (request, response) => {
  var communityName = request.query.communityName;

  pool.query(
    "SELECT * FROM community WHERE LOWER(community_name) LIKE LOWER($1 || '%') AND active = 'T' ORDER BY community_id ASC LIMIT 8",
    [communityName],
    (error, result) => {
      if (error) {
        console.error(error);
        return response.status(500).json({ status: 500, response: error });
      }
      return response.status(200).json({ status: 200, response: result.rows });
    }
  );
};

router.get("/search", search);
router.get("/community/search", communitySearch);

module.exports = router;
