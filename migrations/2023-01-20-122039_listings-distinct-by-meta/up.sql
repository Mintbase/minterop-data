drop view mb_views.active_listings_by_contract;
create view mb_views.active_listings_by_contract as
select
 	c.id as nft_contract_id,
 	c.base_uri,
 	cl.price,
 	cl.created_at,
 	cl.metadata_id,
 	cl.token_id,
 	cl.market_id,
 	cl.approval_id,
 	cl.listed_by,
 	tl.total_listings,
 	cmd.title,
 	cmd.media
from nft_contracts c
left join lateral (
  select distinct on (l.metadata_id)
  	l.price,
  	l.created_at,
  	l.token_id,
  	l.metadata_id,
  	l.market_id,
  	l.approval_id,
  	l.listed_by
  from nft_listings l
  where l.nft_contract_id = c.id and l.unlisted_at is null and l.accepted_at is null and l.invalidated_at is null
  order by l.metadata_id, l.created_at desc
  limit 3
) cl on true
left join lateral (
  select count(*) as total_listings
  from nft_listings l
  where l.nft_contract_id = c.id and l.unlisted_at is null and l.accepted_at is null and l.invalidated_at is null
) tl on true
left join lateral (
  select m.title, m.media -- future! select media type, other ref json fields of interest
  from nft_metadata m
  where cl.metadata_id = m.id and c.id = m.nft_contract_id
  limit 1
) cmd on true
where cl.price is not null; -- omit null lateral appendages