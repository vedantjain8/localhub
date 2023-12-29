# api

To install dependencies:

```bash
bun install
```

To run:

```bash
bun index.js
```

# TODO:
- [ ] stats update from redis > cron job
- [ ] add an endpoint to fetch stats for posts(get post) and community
- [ ] image upload karne ka dekhna h
- [ ] start with login > register > get posts > ... for redis caching
  - [ ] add first caching for views, comments count, join, unjoin community and then add cron job for the same
- [ ] endpoint for debugging to clear all database and recreate from scratch
- [ ] create a docker image

# MAYBE TODOs:
- [ ] create a moderators table, account, mods action page
- [ ] add edited flair to posts when post is edited( logic: when last update time and create_at is not same)

# Dependencies
- [dotenv](https://www.npmjs.com/package/dotenv)
- [express](https://www.npmjs.com/package/express)
- [express-rate-limit](https://www.npmjs.com/package/express-rate-limit)
- [Helmet](https://www.npmjs.com/package/helmet) : Helmet helps secure Express apps by setting HTTP response headers.
- [moment-timezone](https://www.npmjs.com/package/moment-timezone)
- [morgan](https://www.npmjs.com/package/morgan) : Logging
- [redis](https://www.npmjs.com/package/redis)
- [pg](https://www.npmjs.com/package/pg)
- [validator](https://www.npmjs.com/package/validator)
- [node-cron](https://www.npmjs.com/package/node-cron)

# Understand the code
- token is generated from the tools.js using crypto package to generate truely random token key
- the plan is to use the bycrypt algorithm to generate hash password

# Caching naming scheme and store value
- **`userData-${userToken}`**
  - user_id, username, email, bio, avatar_url, created_at, locality_country, locality_state, locality_city
- **`postsPubBy:userID-${user_id}:${offset}`**
  - post_id, post_title, short_content, post_image, community_id, is_adult, created_at, community_name, community_logo_url
- **`posts:offset-${offset}`**
  - post_id, post_title, short_content, post_image, community_id, created_at, community.community_name, community.logo_url
- **`community-${community_id}:posts:offset-${offset}`**
  - post_id, post_title, short_content, post_image, community_id, created_at, community.community_name, community.logo_url
- **`posts:postID-${post_id}`**
  - !! users.username AS post_username
- **`community:joinedCount:${community_id}`**
- community_id, subscriber_count
- **user_community_data**
  - hashes
    - `user:${user_id}:community:${community_id}` : JSON.stringify({ userId: user_id, communityId: community_id, timestamp: new Date().toISOString()})
-