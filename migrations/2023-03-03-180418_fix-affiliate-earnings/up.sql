drop view analytics_tmp.referrer_earnings;
drop view analytics_tmp.referrer_earnings_monthly;
drop view analytics_tmp.referrer_earnings_yearly;
drop view analytics_tmp.affiliate_earnings_monthly;
drop view analytics_tmp.affiliate_earnings_yearly;

create view analytics_tmp.affiliate_earnings as
  select
    receiver_id as affiliate_id,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
	select receiver_id, amount
    from nft_earnings
    where is_affiliate = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by receiver_id
  order by receiver_id
;

create view analytics_tmp.affiliate_earnings_monthly as
  select
    date_trunc,
    receiver_id as affiliate_id,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
    select
      to_date(to_char(timestamp, 'YYYY-MM'), 'YYYY-MM') as date_trunc,
      receiver_id,
      amount
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
    select
      to_date(to_char(timestamp, 'YYYY'), 'YYYY') as date_trunc,
      receiver_id,
      amount
    from nft_earnings
    where is_affiliate = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by date_trunc, receiver_id
  order by date_trunc, receiver_id
;
