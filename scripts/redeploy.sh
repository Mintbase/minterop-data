#!/usr/bin/env bash

network="$1"

read -r -d '' HASURA_GRANTS <<EOF
grant connect on database minterop to hasura;
grant select on all tables in schema public to hasura;
grant select on all tables in schema mb_views to hasura;
grant select on all sequences in schema mb_views to hasura;
grant usage on schema mb_views to hasura;
EOF

source "$network.env" || exit 1

# run diesel migrations
DATABASE_URL="$POSTGRES" diesel migration run || exit 1

# hasura project reload metadata
(
  cd ../hasura || exit 1
  hasura metadata apply --envfile "../$network.env"
) || exit 1

# grant privileges to hasura user
psql "$POSTGRES" -c "$HASURA_GRANTS"
