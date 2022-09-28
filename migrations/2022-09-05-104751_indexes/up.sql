-- fix dragonnation
update nft_contracts
set
	base_uri = 'https://bafybeidq7nu5pxsiy2cext6qtxxygpifhunxco25mtrabfge2rf6lxdax4.ipfs.dweb.link/',
	is_mintbase = FALSE
where id = 'dragonnation.near';

-- adding minter to nft_metadata
alter table nft_metadata add column minter text;
update nft_metadata
set minter = t.minter
from (
	select distinct on (metadata_id) metadata_id, minter
	from nft_tokens
	order by metadata_id, minted_timestamp asc
) t
where t.metadata_id = nft_metadata.id;

-- adding base_uri to nft_metadata
alter table nft_metadata add column base_uri text;
update nft_metadata
set base_uri = nft_contracts.base_uri
from nft_contracts
where nft_contracts.id = nft_metadata.nft_contract_id;

-- adding metadata_id to nft_listings
alter table nft_listings add column metadata_id text;
update nft_listings
set metadata_id = nft_tokens.metadata_id
from nft_tokens
where nft_tokens.nft_contract_id = nft_listings.nft_contract_id
  and nft_tokens.token_id = nft_listings.token_id;

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
  l.metadata_id,
  m.reference,
  m.minter,
  m.title,
  m.description,
  m.reference_blob,
  m.media,
  m.extra
from nft_listings l
  left join nft_metadata m
  on l.metadata_id = m.id
where l.unlisted_at is null
  and l.accepted_at is null;

create view mb_views.active_listings_rollup
as select distinct on (metadata_id)
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
  l.metadata_id,
  m.reference,
  m.minter,
  m.title,
  m.description,
  m.reference_blob,
  m.media,
  m.extra
from nft_listings l
  left join nft_metadata m
  on l.metadata_id = m.id
where l.unlisted_at is null
  and l.accepted_at is null
order by metadata_id, price;

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

-- indexes
create index nft_listings_price_index on nft_listings (metadata_id, price, unlisted_at, accepted_at);
create index nft_tokens_metadata_id_index on nft_tokens(metadata_id, burned_timestamp);
