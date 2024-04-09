#!/bin/bash

DATABASE_URL=postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_DATABASE} bun run migrate up --no-verbose

bun index.js