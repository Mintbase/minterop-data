drop view mb_views.nft_activities;
drop view analytics_tmp.affiliate_earnings;
drop view analytics_tmp.affiliate_earnings_monthly;
drop view analytics_tmp.affiliate_earnings_yearly;

-- add currency to activities table
alter table nft_activities add currency text;

create view mb_views.nft_activities as
  select
    a.receipt_id,
    a.tx_sender,
    a.timestamp,
    a.nft_contract_id,
    a.token_id,
    a.kind,
    a.action_sender,
    a.action_receiver,
    a.price,
    a.currency,
    t.reference,
    t.reference_hash,
    t.copies,
    t.metadata_id,
    m.title,
    m.description,
    m.media,
    m.media_hash,
    m.extra,
    m.reference_blob,
    m.content_flag
  from nft_activities a
    left join nft_tokens t
      on a.nft_contract_id = t.nft_contract_id
      and a.token_id = t.token_id
    left join nft_metadata m
      on t.metadata_id = m.id;

create view analytics_tmp.affiliate_earnings as
  select
    receiver_id as affiliate_id,
    currency,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
	select receiver_id, currency, amount
    from nft_earnings
    where is_affiliate = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by receiver_id, currency
  order by receiver_id, currency
;

create view analytics_tmp.affiliate_earnings_monthly as
  select
    date_trunc,
    receiver_id as affiliate_id,
    currency,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
    select
      to_date(to_char(timestamp, 'YYYY-MM'), 'YYYY-MM') as date_trunc,
      receiver_id,
      currency,
      amount
    from nft_earnings
    where is_affiliate = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by date_trunc, receiver_id, currency
  order by date_trunc, receiver_id, currency
;

create view analytics_tmp.affiliate_earnings_yearly as
  select
    date_trunc,
    receiver_id as affiliate_id,
    currency,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
    select
      to_date(to_char(timestamp, 'YYYY'), 'YYYY') as date_trunc,
      receiver_id,
      currency,
      amount
    from nft_earnings
    where is_affiliate = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by date_trunc, receiver_id, currency
  order by date_trunc, receiver_id, currency
;
