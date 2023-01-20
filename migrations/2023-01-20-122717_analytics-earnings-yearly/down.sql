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

drop view analytics_tmp.referrer_earnings_monthly;
drop view analytics_tmp.referrer_earnings_yearly;
