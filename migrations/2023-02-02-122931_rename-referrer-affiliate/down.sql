drop view analytics_tmp.affiliate_earnings_monthly;
drop view analytics_tmp.affiliate_earnings_yearly;

-- migrate column in nft_earnings
alter table nft_earnings drop column is_affiliate;

-- migrate columns in
alter table nft_earnings drop column affiliate_id;
alter table nft_earnings drop column affiliate_amount;
