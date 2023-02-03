#!/usr/bin/env bash

fail() {
  echo "$2"
  exit "$1"
}

quietly() {
  "$@" >/dev/null 2>&1
}

quietly docker kill postgresDB
quietly docker rm postgresDB

docker network inspect minterop >/dev/null 2>&1 ||
  docker network create minterop

docker run --name postgresDB \
  -e POSTGRES_USER="postgres" \
  -e POSTGRES_PASSWORD="password" \
  -e POSTGRES_DB="minterop" \
  --network minterop --network-alias postgres \
  -p "5432:5432" -d postgres ||
  fail "$?" "Failed to run postgres container"
export POSTGRES='postgres://postgres:password@127.0.0.1:5432/minterop'
sleep 3 # wait until postgres is ready

# Use this to generate a valid `schema.rs` and truncate the DB
(
  export DATABASE_URL="$POSTGRES"
  diesel migration run || exit "$?"
) || fail "$?" "Failed to migrate database"
