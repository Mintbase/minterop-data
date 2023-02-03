-- migrate column in nft_earnings (duplication to give FE and users a grace
-- period for implementing the rename)
alter table nft_earnings add column is_affiliate boolean;
update nft_earnings set is_affiliate = is_referral;

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
