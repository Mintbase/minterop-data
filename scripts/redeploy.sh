#!/usr/bin/env bash

network="$1"

read -r -d '' HASURA_GRANTS <<EOF
grant connect on database minterop to hasura;
grant select on all tables in schema public to hasura;
grant select on all tables in schema mb_views to hasura;
grant trigger on public.nft_offers to hasura;
grant select on all sequences in schema mb_views to hasura;
grant usage on schema mb_views to hasura;
EOF

read -r -d '' POSTGRES_GRANTS <<EOF
grant usage on schema hdb_catalog to postgres;
grant select on all tables in schema hdb_catalog to postgres;
grant insert on all tables in schema hdb_catalog to postgres;
EOF

source "$network.env" || exit 1

# run diesel migrations
DATABASE_URL="$POSTGRES" diesel migration run || exit 1

# hasura project reload metadata
(
  cd ./hasura || exit 1
  hasura metadata apply --envfile "../$network.env"
) || exit 1

# grant privileges to hasura user
psql "$POSTGRES" -c "$HASURA_GRANTS" || exit 1
psql "$HASURA_POSTGRES" -c "$POSTGRES_GRANTS" || exit 1
