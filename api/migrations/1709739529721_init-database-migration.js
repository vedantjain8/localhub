/* eslint-disable camelcase */

exports.shorthands = undefined;

exports.up = async (pgm) => {
  await pgm.createTable("users", {
    user_id: { type: "serial", primaryKey: true },
    username: { type: "varchar(15)", notNull: true },
    email: { type: "varchar(30)", notNull: true },
    password_hash: { type: "varchar(255)", notNull: true },
    bio: { type: "text" },
    avatar_url: { type: "varchar(255)" },
    created_at: {
      type: "timestamp",
      notNull: true,
      default: pgm.func("NOW()"),
    },
    last_login: { type: "timestamp" },
    locality_country: { type: "varchar", notNull: true },
    locality_state: { type: "varchar", notNull: true },
    locality_city: { type: "varchar", notNull: true },
    active: { type: "boolean", notNull: true, default: true },
    token: { type: "varchar(25)", notNull: true },
  });

  await pgm.createTable("community", {
    community_id: { type: "serial", primaryKey: true },
    community_name: { type: "varchar(60)", notNull: true, unique: true },
    community_description: { type: "text" },
    creator_user_id: {
      type: "int",
      notNull: true,
      references: "users(user_id)",
    },
    created_at: {
      type: "timestamp",
      notNull: true,
      default: pgm.func("NOW()"),
    },
    banner_url: { type: "varchar(255)" },
    logo_url: { type: "varchar(255)", notNull: true },
    active: { type: "boolean", notNull: true, default: true },
  });

  await pgm.createTable("community_stats", {
    community_id: {
      type: "int",
      primaryKey: true,
      notNull: true,
      references: "community(community_id)",
    },
    subscriber_count: { type: "int", default: 0 },
  });

  await pgm.createFunction(
    "community_stats_insert_function",
    [],
    { returns: "trigger", language: "plpgsql", replace: true },
    `
      BEGIN
      INSERT INTO community_stats (community_id, subscriber_count)
      VALUES (NEW.community_id, 0);
      RETURN NEW;
      END;
      `
  );

  await pgm.createTrigger("community", "community_stats_insert_trigger", {
    when: "AFTER",
    operation: "INSERT",
    language: "plpgsql",
    level: "ROW",
    replace: true,
    function: "community_stats_insert_function",
  });

  await pgm.createTable("users_community_link", {
    user_id: { type: "int", notNull: true, references: "users(user_id)" },
    community_id: {
      type: "int",
      notNull: true,
      references: "community(community_id)",
    },
    joined_at: { type: "timestamp", notNull: true, default: pgm.func("NOW()") },
  });

  await pgm.createTable("posts", {
    post_id: { type: "serial", primaryKey: true },
    post_title: { type: "varchar(200)", notNull: true },
    post_content: { type: "text", notNull: true },
    post_image: { type: "text" },
    user_id: { type: "int", notNull: true, references: "users(user_id)" },
    community_id: {
      type: "int",
      notNull: true,
      references: "community(community_id)",
    },
    is_adult: { type: "boolean", notNull: true, default: false },
    created_at: {
      type: "timestamp",
      notNull: true,
      default: pgm.func("NOW()"),
    },
    active: { type: "boolean", notNull: true, default: true },
  });

  await pgm.createTable("posts_stats", {
    post_id: {
      type: "int",
      primaryKey: true,
      notNull: true,
      references: "posts(post_id)",
    },
    total_votes: { type: "int", default: 0 },
    total_views: { type: "int", default: 0 },
    total_comments: { type: "int", default: 0 },
  });

  await pgm.createFunction(
    "posts_stats_insert_function",
    [],
    { returns: "trigger", language: "plpgsql", replace: true },
    `
        BEGIN
        INSERT INTO posts_stats (post_id, total_votes, total_views, total_comments)
        VALUES (NEW.post_id, 0, 0, 0);
        RETURN NEW;
        END;
    `
  );

  await pgm.createTrigger("posts", "posts_stats_insert_trigger", {
    when: "AFTER",
    operation: "INSERT",
    language: "plpgsql",
    level: "ROW",
    replace: true,
    function: "posts_stats_insert_function",
  });

  await pgm.createTable("posts_vote_link", {
    vote_id: { type: "serial", primaryKey: true },
    post_id: { type: "int", notNull: true, references: "posts(post_id)" },
    user_id: { type: "int", notNull: true, references: "users(user_id)" },
    vote_type: { type: "varchar(10)", notNull: true },
    vote_date: { type: "timestamp", notNull: true, default: pgm.func("NOW()") },
  });

  await pgm.createConstraint("posts_vote_link", "unique_user_vote_posts", {
    unique: ["user_id", "post_id"],
  });

  await pgm.createTable("report_posts", {
    report_id: { type: "serial", primaryKey: true },
    user_id: { type: "int", notNull: true, references: "users(user_id)" },
    post_id: { type: "int", notNull: true, references: "posts(post_id)" },
    report_time: {
      type: "timestamp",
      notNull: true,
      default: pgm.func("NOW()"),
    },
  });

  await pgm.createConstraint("report_posts", "unique_user_report_posts", {
    unique: ["user_id", "post_id"],
  });

  await pgm.createTable("posts_comments_link", {
    comment_id: { type: "serial", primaryKey: true },
    post_id: { type: "int", notNull: true, references: "posts(post_id)" },
    user_id: { type: "int", notNull: true, references: "users(user_id)" },
    comment_content: { type: "varchar", notNull: true },
    active: { type: "boolean", notNull: true, default: true },
    created_at: { type: "timestamp", notNull: true, default: pgm.func("NOW()") },
  });

  await pgm.createTable("report_comment", {
    report_id: { type: "serial", primaryKey: true },
    user_id: { type: "int", notNull: true, references: "users(user_id)" },
    comment_id: {
      type: "int",
      notNull: true,
      references: "posts_comments_link(comment_id)",
    },
    report_time: {
      type: "timestamp",
      notNull: true,
      default: pgm.func("NOW()"),
    },
  });

  await pgm.createConstraint("report_comment", "unique_user_report_comments", {
    unique: ["user_id", "comment_id"],
  });

  await pgm.createTable("image_upload_log", {
    upload_tag: { type: "serial", primaryKey: true },
    user_id: { type: "int", notNull: true, references: "users(user_id)" },
    image_name: { type: "varchar(255)", notNull: true },
    image_url: { type: "text", notNull: true },
  });
};

exports.down = (pgm) => {};
