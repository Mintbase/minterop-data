alter table nft_offers add column expires_at timestamp;
update nft_offers
set expires_at = offered_at + interval '1 day'
where market_id = 'market.mintbase1.near';