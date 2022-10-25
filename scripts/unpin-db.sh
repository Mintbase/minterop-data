#!/usr/bin/env bash

source "$1.env"

# This query unpins by dropping all hasura connections. Nuclear option.
sql="select pg_terminate_backend(pid) from pg_stat_activity where usename = 'hasura';"

# This query unpins by only dropping hasura connections that run longer than 15
# seconds, keeping performant functionality of omni-site intact.
read -r -d '' sql <<EOF
select pg_terminate_backend(pid)
from pg_stat_activity
where usename = 'hasura'
  and (now() - query_start) > interval '15 seconds';
EOF

# Every 2 seconds, 7200 times -> unpins DB for 4 hours. Usually running this
# script for a few minutes while possibly fixing underlying issues is
# sufficient.
for _ in $(seq 7200); do
  psql "$POSTGRES" -c "$sql"
  sleep 2
done
