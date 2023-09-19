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
