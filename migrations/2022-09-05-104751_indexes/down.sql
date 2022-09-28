alter table nft_metadata drop column minter;
alter table nft_metadata drop column base_uri;
alter table nft_listings drop column metadata_id;

drop view mb_views.nft_metadata_unburned;
drop view mb_views.nft_tokens_with_listing;
drop view mb_views.active_listings_rollup;
drop view mb_views.active_listings;

create view mb_views.active_listings
as select
  l.nft_contract_id,
  l.token_id,
  l.market_id,
  l.approval_id,
  l.created_at,
  l.receipt_id,
  l.kind,
  l.price,
  l.currency,
  l.listed_by,
  t.reference,
  t.minter,
  t.copies,
  m.title,
  m.description,
  m.reference_blob,
  m.media,
  m.extra,
  t.metadata_id
from nft_listings l
  left join nft_tokens t
    on l.nft_contract_id = t.nft_contract_id
    and l.token_id = t.token_id
  left join nft_metadata m
    on t.metadata_id = m.id
where l.unlisted_at is null
  and l.accepted_at is null
  and t.owner = l.listed_by;

create view mb_views.active_listings_rollup
as select distinct on (metadata_id) * from (
  select * from mb_views.active_listings order by price asc
) l;

-- unchanged, needs to be recreated due to dependency
create view mb_views.nft_metadata_unburned as
select
	m.id as metadata_id,
	m.title,
	m.description,
	m.media,
	t.nft_contract_id,
	t.minted_timestamp,
  t.minter,
	l.price
from nft_metadata m
left join (
  select distinct on (metadata_id) *
  from nft_tokens
  order by metadata_id, minted_timestamp, burned_timestamp
) t on m.id=t.metadata_id
left join mb_views.active_listings_rollup l on m.id=l.metadata_id
where t.burned_timestamp is null;

-- unchanged, needs to be recreated due to dependency
create view mb_views.nft_tokens_with_listing as
select
	t.nft_contract_id,
	t.token_id,
	t.owner,
	t.metadata_id,
	l.price
from nft_tokens t
left join mb_views.active_listings l on l.nft_contract_id=t.nft_contract_id
where t.burned_timestamp is null;

drop index nft_listings_price_index;
drop index nft_tokens_metadata_id_index;
