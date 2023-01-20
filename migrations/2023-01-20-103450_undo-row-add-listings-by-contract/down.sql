drop view mb_views.active_listings_by_contract;
drop view mb_views.nft_metadata_unburned;
drop view mb_views.active_listings_by_contract;

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
  l.price,
  row_number() over (partition by nft_contract_id) as row_number
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
