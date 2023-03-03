create view analytics_tmp.referrer_earnings as
  select
    date_trunc,
    receiver_id as referrer_id,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
	select date_trunc('month', timestamp)::date, receiver_id, amount
    from nft_earnings
    where is_referral = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by date_trunc, receiver_id
  order by date_trunc, receiver_id
;

create view analytics_tmp.referrer_earnings_monthly as
  select
    date_trunc,
    receiver_id as referrer_id,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
	select date_trunc('month', timestamp)::date, receiver_id, amount
    from nft_earnings
    where is_referral = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by date_trunc, receiver_id
  order by date_trunc, receiver_id
;

create view analytics_tmp.referrer_earnings_yearly as
  select
    date_trunc,
    receiver_id as referrer_id,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
	select date_trunc('month', timestamp)::date, receiver_id, amount
    from nft_earnings
    where is_referral = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by date_trunc, receiver_id
  order by date_trunc, receiver_id
;

-- migrate columns in nft_offers (duplication with same reasoning)
alter table nft_offers add column affiliate_id text;
update nft_offers set affiliate_id = referrer_id;
alter table nft_offers add column affiliate_amount numeric;
update nft_offers set affiliate_amount = referral_amount;

create view analytics_tmp.affiliate_earnings_monthly as
  select
    date_trunc,
    receiver_id as affiliate_id,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
	select date_trunc('month', timestamp)::date, receiver_id, amount
    from nft_earnings
    where is_affiliate = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by date_trunc, receiver_id
  order by date_trunc, receiver_id
;

create view analytics_tmp.affiliate_earnings_yearly as
  select
    date_trunc,
    receiver_id as affiliate_id,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
	select date_trunc('month', timestamp)::date, receiver_id, amount
    from nft_earnings
    where is_affiliate = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by date_trunc, receiver_id
  order by date_trunc, receiver_id
;
