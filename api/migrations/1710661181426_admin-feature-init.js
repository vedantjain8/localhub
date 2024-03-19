/* eslint-disable camelcase */

exports.shorthands = undefined;

exports.up = (pgm) => {
  pgm.addColumns("users", {
    user_role: {
      type: "INT",
      notNull: true,
      default: 0,
    },
  });

  pgm.sql(`
        UPDATE users
        SET user_role = 0
        WHERE user_role IS NULL
    `);

  pgm.createTable("adminLog", {
    log_id: {
      type: "serial",
      primaryKey: true,
    },
    user_id: {
      type: "INT",
      notNull: true,
      references: "users(user_id)",
    },
    logEvent: {
      type: "varchar(50)",
      notNull: true,
    },
    logDescription: {
      type: "text",
    },
    created_at: {
      type: "timestamp",
      notNull: true,
      default: pgm.func("NOW()"),
    },
  });

  pgm.createTable("agenda", {
    event_id: {
      type: "serial",
      primaryKey: true,
    },
    event_title: {
      type: "varchar(100)",
      notNull: true,
    },
    event_description: {
      type: "text",
    },
    user_id: {
      type: "INT",
      notNull: true,
      references: "users(user_id)",
    },
    image_url: {
      type: "text",
    },
    locality_city: {
      type: "varchar(100)",
      notNull: true,
    },
    locality_state: {
      type: "varchar(100)",
      notNull: true,
    },
    locality_country: {
      type: "varchar(100)",
      notNull: true,
    },
    event_start_date: {
      type: "timestamp",
      notNull: true,
    },
    event_end_date: {
      type: "timestamp",
      notNull: true,
    },
    created_at: {
      type: "timestamp",
      notNull: true,
      default: pgm.func("NOW()"),
    },
  });
};

exports.down = (pgm) => {};
