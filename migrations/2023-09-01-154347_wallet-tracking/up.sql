-- FIXME: add receipt_id or transaction_id for linking
create table access_keys (
    account_id         text      not null,
    public_key         text      not null,
    created_at         timestamp not null,
    created_receipt_id text      not null,
    removed_at         timestamp,
    removed_receipt_id text,
    primary key(account_id, public_key, created_at)
);

create table accounts (
    account_id         text      not null,
    created_at         timestamp not null,
    created_receipt_id text      not null,
    removed_at         timestamp,
    removed_receipt_id text,
    beneficiary_id     text,
    primary key(account_id, created_at)
);

-- temporary tracking for running two indexers on the same DB, such that
-- we can index historical data for new tables without compromising processing
-- of current data
alter table blocks add synced_height_tmp bigint;
