# api

To install dependencies:

```bash
bun install
```

To run:

```bash
bun index.js
```
> [!CAUTION]
> ssl certificates are self signed certs that should not be used in production. 
> It is recommended to use a valid CA or use lets encrypt for a ssl certificate.

# TODO:
- [ ] stats update from redis > cron job
  - [ ] votes - redis - status update
- [ ] ip post view count increment limiting
- [ ] admin page endpoint
- [ ] endpoint for debugging to clear all database and recreate from scratch
- [ ] create a docker image 
  - [ ] read [this](https://dev.to/duncanlew/best-practices-for-reducing-the-docker-image-size-for-a-nodejs-application-2m7a) article and [this, along with recommended articles at end](https://blog.devgenius.io/reduce-the-size-of-your-node-js-docker-image-by-up-to-90-53aad23890e2)
- [ ] for nginx config - [this](https://stackoverflow.com/a/54403319)
- [ ] [easy ways to speed up express article](https://stackabuse.com/6-easy-ways-to-speed-up-express/)

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
- [multer](https://www.npmjs.com/package/multer)
- [sharp](https://www.npmjs.com/package/sharp)

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
- **`comments:postID-${post_id}:${offset}`**
  - comment_id, users.username, comment_content, created_at, users.avatar_url
- **`user${user_id}:voteType${vote}:${offset}`**
  - same as post
- **`community:stats:${community_id}`**
  - subscriber_count
- **`post:stats:${post_id}`**
  - total_votes, total_views, total_comments