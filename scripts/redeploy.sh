#!/usr/bin/env bash

read -r -d '' HASURA_GRANTS <<EOF
grant connect on database minterop to hasura;
grant select on all tables in schema public to hasura;
grant select on all tables in schema mb_views to hasura;
grant select on all sequences in schema mb_views to hasura;
grant usage on schema mb_views to hasura;
EOF

# Stop indexing while doing migrations, otherwise good chances of DB corruption
# between migration and indexer redeployment
gcloud compute instances delete "interop-indexer-$network" -q \
  --project=omni-cloud-1 \
  --zone=europe-west1-b

(
  source "$network.env" || exit 1
  cd minterop-common || exit 1
  # revert creating views
  DATABASE_URL="$POSTGRES" diesel migration revert || exit 1
  # revert creating database itself
  DATABASE_URL="$POSTGRES" diesel migration revert || exit 1
  # create the schema
  DATABASE_URL="$POSTGRES" diesel migration run || exit 1

  # hasura project reload metadata
  cd ../hasura || exit 1
  hasura metadata apply --envfile "../$network.env"

  # grant privileges to hasura user
  psql "$POSTGRES" -c "$HASURA_GRANTS"

  # TODO: merging data -> takes a long long time
) || exit 1

