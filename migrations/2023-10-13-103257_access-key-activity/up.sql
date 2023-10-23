create view mb_views.access_key_activity as
select * from (
  select
    created_at as timestamp,
    created_receipt_id as receipt_id,
    account_id,
    public_key,
    'add' as kind
  from access_keys
  union all
  select
    removed_at as timestamp,
    removed_receipt_id as receipt_id,
    account_id,
    public_key,
    'del' as kind
  from access_keys where removed_at is not null
) a
order by timestamp desc;
