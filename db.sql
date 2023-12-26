CREATE TABLE IF NOT EXISTS
  users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(15) NOT NULL,
    email VARCHAR(30) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    salt VARCHAR(15) NOT NULL,
    bio TEXT,
    avatar_url VARCHAR(255),
    karma INT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW (),
    last_login TIMESTAMP,
    country VARCHAR(20) NOT NULL DEFAULT 'global',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    token VARCHAR(25) NOT NULL
  );

CREATE TABLE IF NOT EXISTS
  subreddit (
    subreddit_id SERIAL PRIMARY KEY,
    subreddit_name VARCHAR(60) NOT NULL UNIQUE,
    subreddit_description TEXT,
    creator_user_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    is_adult BOOLEAN DEFAULT FALSE,
    banner_url VARCHAR(255),
    logo_url VARCHAR(255) NOT NULL,
    subscriber_count INT DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (creator_user_id) REFERENCES users (user_id)
  );

CREATE TABLE IF NOT EXISTS
  posts (
    post_id SERIAL PRIMARY KEY,
    post_title VARCHAR(200) NOT NULL,
    post_content TEXT NOT NULL,
    image TEXT,
    user_id INT NOT NULL,
    subreddit_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    total_votes INT DEFAULT 0,
    total_views INT DEFAULT 0,
    total_comments INT DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (subreddit_id) REFERENCES subreddit (subreddit_id)
  );

CREATE TABLE IF NOT EXISTS
  post_vote_link (
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
  comments_link(
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
  user_subreddit_link(
    user_id INT NOT NULL,
    subreddit_id INT NOT NULL,
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (subreddit_id) REFERENCES subreddit(subreddit_id),
    UNIQUE (user_id, subreddit_id)
  );

CREATE TABLE IF NOT EXISTS
  report_comment(
    report_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    comment_id INT NOT NULL,
    report_time TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (comment_id) REFERENCES comments_link(comment_id),
    UNIQUE (user_id, comment_id)
  );

CREATE TABLE IF NOT EXISTS
  report_post(
    report_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    report_time TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (post_id) REFERENCES posts (post_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    UNIQUE (user_id, post_id)
  );

CREATE OR REPLACE FUNCTION update_total_votes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    UPDATE posts
    SET total_votes = total_votes - (CASE WHEN OLD.vote_type = 'U' THEN 1 WHEN OLD.vote_type = 'D' THEN -1 ELSE 0 END)
    WHERE post_id = OLD.post_id;
  END IF;

  UPDATE posts
  SET total_votes = total_votes + (CASE WHEN NEW.vote_type = 'U' THEN 1 WHEN NEW.vote_type = 'D' THEN -1 ELSE 0 END)
  WHERE post_id = NEW.post_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER update_total_votes_trigger
AFTER INSERT OR UPDATE
ON post_vote_link
FOR EACH ROW
EXECUTE FUNCTION update_total_votes();

CREATE OR REPLACE FUNCTION update_total_comments()
RETURNS TRIGGER AS $$
BEGIN

  UPDATE posts
  SET total_comments = total_comments + 1
  WHERE post_id = NEW.post_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER update_total_comments_trigger
AFTER INSERT
ON comments_link
FOR EACH ROW
EXECUTE FUNCTION update_total_comments();
