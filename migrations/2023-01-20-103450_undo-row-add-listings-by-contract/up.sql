-- undo row thing
drop view mb_views.nft_metadata_unburned;

create view mb_views.nft_metadata_unburned as
select md.id as metadata_id,
  md.title,
  md.description,
  md.media,
  md.nft_contract_id,
  md.base_uri,
  md.reference_blob,
  md.content_flag,
  t.minted_timestamp,
  t.minter,
  l.price
from nft_metadata md
left join lateral (
  select
    t.minted_timestamp,
    t.minter
  from nft_tokens t
  where t.burned_timestamp is null and t.metadata_id = md.id
    order by t.minted_timestamp desc
    LIMIT 1
) t on true
left join lateral (
  select p.price
  from nft_listings p
  where
    p.unlisted_at is null and
    p.accepted_at is null and
    p.invalidated_at is null and
    p.metadata_id = md.id
  order by p.price asc
  limit 1
) l on true;

-- add listings by contract view
-- todo: neat things like adding attributes to this view, geolocation etc. etc.
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
  select
  	l.price,
  	l.created_at,
  	l.token_id,
  	l.metadata_id,
  	l.market_id,
  	l.approval_id,
  	l.listed_by
  from nft_listings l
  where l.nft_contract_id = c.id and l.unlisted_at is null and l.accepted_at is null and l.invalidated_at is null
  order by l.created_at desc
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
where cl.price is not null -- omit null lateral appendages
