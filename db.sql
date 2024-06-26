CREATE TABLE IF NOT EXISTS
  users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(15) NOT NULL,
    email VARCHAR(30) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    bio TEXT,
    avatar_url VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW (),
    last_login TIMESTAMP,
    locality_country VARCHAR NOT NULL,
    locality_state VARCHAR NOT NULL,
    locality_city VARCHAR NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    token VARCHAR(25) NOT NULL,
    user_role INT NOT NULL DEFAULT 0
  );

CREATE TABLE IF NOT EXISTS
  community (
    community_id SERIAL PRIMARY KEY,
    community_name VARCHAR(60) NOT NULL UNIQUE,
    community_description TEXT,
    creator_user_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    banner_url VARCHAR(255),
    logo_url VARCHAR(255) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (creator_user_id) REFERENCES users (user_id)
  );

CREATE TABLE IF NOT EXISTS 
  community_stats(
    community_id INT NOT NULL PRIMARY KEY,
    subscriber_count INT DEFAULT 0,
    FOREIGN KEY (community_id) REFERENCES community (community_id)
  );

CREATE OR REPLACE FUNCTION community_stats_insert_function()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO community_stats (community_id, subscriber_count)
  VALUES (NEW.community_id, 0);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER community_stats_insert_trigger
AFTER INSERT ON community
FOR EACH ROW
EXECUTE FUNCTION community_stats_insert_function();

CREATE TABLE IF NOT EXISTS
  users_community_link(
    user_id INT NOT NULL,
    community_id INT NOT NULL,
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (community_id) REFERENCES community(community_id),
    UNIQUE (user_id, community_id)
  );

CREATE TABLE IF NOT EXISTS
  posts (
    post_id SERIAL PRIMARY KEY,
    post_title VARCHAR(200) NOT NULL,
    post_content TEXT,
    post_image TEXT,
    user_id INT NOT NULL,
    community_id INT NOT NULL,
    is_adult BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (community_id) REFERENCES community (community_id)
  );

  CREATE TABLE IF NOT EXISTS
    posts_stats (
      post_id INT PRIMARY KEY, 
      total_votes INT DEFAULT 0,
      total_views INT DEFAULT 0,
      total_comments INT DEFAULT 0,
      FOREIGN KEY (post_id) REFERENCES posts (post_id)
    );

CREATE OR REPLACE FUNCTION posts_stats_insert_function()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO posts_stats (post_id, total_votes, total_views, total_comments)
  VALUES (NEW.post_id, 0, 0, 0);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER posts_stats_insert_trigger
AFTER INSERT ON posts
FOR EACH ROW
EXECUTE FUNCTION posts_stats_insert_function();


CREATE TABLE IF NOT EXISTS
  posts_vote_link (
    vote_id SERIAL PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    vote_type VARCHAR(1) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (post_id) REFERENCES posts (post_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    UNIQUE(user_id, post_id)
  );

  CREATE TABLE IF NOT EXISTS
  report_posts(
    report_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    report_time TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (post_id) REFERENCES posts (post_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    UNIQUE (user_id, post_id)
  );

CREATE TABLE IF NOT EXISTS
  posts_comments_link(
    comment_id SERIAL PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_content VARCHAR NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (post_id) REFERENCES posts (post_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id)
  );

CREATE TABLE IF NOT EXISTS
  report_comment(
    report_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    comment_id INT NOT NULL,
    report_time TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (comment_id) REFERENCES posts_comments_link(comment_id),
    UNIQUE (user_id, comment_id)
  );

CREATE TABLE IF NOT EXISTS
  image_upload_log(
    upload_tag SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    image_name VARCHAR NOT NULL,
    image_url TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
  );

CREATE TABLE IF NOT EXISTS
  adminlog(
    log_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    log_event VARCHAR(50) NOT NULL,
    log_description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
  );


CREATE TABLE IF NOT EXISTS
  agenda(
    agenda_id SERIAL PRIMARY KEY,
    agenda_title VARCHAR(100) NOT NULL,
    agenda_description TEXT NOT NULL,
    user_id INT NOT NULL,
    image_url TEXT,
    locality_city VARCHAR NOT NULL,
    locality_state VARCHAR NOT NULL,
    locality_country VARCHAR NOT NULL,
    agenda_start_date TIMESTAMP NOT NULL,
    agenda_end_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
  )