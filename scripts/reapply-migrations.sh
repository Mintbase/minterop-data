#!/usr/bin/env bash

# This script is mostly for deving and quick-rolling migrations/changing +
# reapplying them

network="$1"

read -r -d '' HASURA_GRANTS <<EOF
grant connect on database minterop to hasura;
grant select on all tables in schema public to hasura;
grant select on all tables in schema mb_views to hasura;
grant select on all sequences in schema mb_views to hasura;
grant usage on schema mb_views to hasura;
EOF

(
  source "$network.env" || exit 1
  cd minterop-common || exit 1
  DATABASE_URL="$POSTGRES" diesel migration redo
) || exit 1

(
  cd hasura || exit 1
  hasura metadata apply --envfile "../$network.env" || exit 1
  hasura metadata ic list --envfile "../$network.env"
) || exit 1

(source "$network.env" && psql "$POSTGRES" -c "$HASURA_GRANTS") || exit 1
