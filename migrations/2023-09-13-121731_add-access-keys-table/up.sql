create table access_keys (
    account_id  text      not null,
    public_key  text      not null,
    permissions jsonb,
    created_at  timestamp not null,
    removed_at  timestamp,
    primary key(account_id, public_key, created_at)
);
