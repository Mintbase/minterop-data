drop view mb_views.nft_metadata_unburned;

create view mb_views.nft_metadata_unburned as
select
	m.id as metadata_id,
	m.title,
	m.description,
	m.media,
	m.nft_contract_id,
  m.base_uri,
  m.reference_blob,
	t.minted_timestamp,
  t.minter,
	l.price
from nft_metadata m
inner join (
  select distinct on (metadata_id) *
  from nft_tokens
  where burned_timestamp is null
) t on m.id=t.metadata_id
left join (
  select distinct on (metadata_id) metadata_id, price
  from nft_listings
  where unlisted_at is null
    and accepted_at is null
    and invalidated_at is null
  order by metadata_id, price
) l on m.id=l.metadata_id;
