create table access_keys (
    account_id  text      not null,
    public_key  text      not null,
    permissions jsonb,
    created_at  timestamp not null,
    removed_at  timestamp,
    primary key(account_id, public_key, created_at)
);

create table accounts (
    account_id      text      not null,
    amount          text      not null,
    locked          text      not null,
    code_hash       text      not null,
    storage_usage   numeric   not null,
    storage_paid_at numeric   not null,
    created_at      timestamp not null,
    removed_at      timestamp,
    primary key(account_id)
);

-- temporary tracking for running two indexers on the same DB, such that
-- we can index historical data for new tables without compromising processing
-- of current data
alter table blocks add synced_height_tmp bigint;
