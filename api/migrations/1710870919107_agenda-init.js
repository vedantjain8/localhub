/* eslint-disable camelcase */

exports.shorthands = undefined;

exports.up = (pgm) => {
  pgm.createTable("agenda", {
    agenda_id: {
      type: "serial",
      primaryKey: true,
    },
    agenda_title: {
      type: "varchar(100)",
      notNull: true,
    },
    agenda_description: {
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
    agenda_start_date: {
      type: "timestamp",
      notNull: true,
    },
    agenda_end_date: {
      type: "timestamp",
      notNull: true,
    },
    created_at: {
      type: "timestamp",
      notNull: true,
      default: pgm.func("NOW()"),
    },
    active: {
      type: "boolean",
      notNull: true,
      default: true,
    },
  });
};

exports.down = (pgm) => {};
