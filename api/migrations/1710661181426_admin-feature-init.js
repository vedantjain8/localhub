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

  pgm.createTable("adminlog", {
    log_id: {
      type: "serial",
      primaryKey: true,
    },
    user_id: {
      type: "INT",
      notNull: true,
      references: "users(user_id)",
    },
    log_event: {
      type: "varchar(50)",
      notNull: true,
    },
    log_description: {
      type: "text",
    },
    created_at: {
      type: "timestamp",
      notNull: true,
      default: pgm.func("NOW()"),
    },
  });
};

exports.down = (pgm) => {};
