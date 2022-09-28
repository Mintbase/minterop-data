-- different schema for all the views
create schema mb_views;

-- -------------------- NFT Core and Metadata standards --------------------- --

-- This equates to the old things table, with all data as needed (hopefully)
create view mb_views.nft_metadata as
select
  m.id,
  m.nft_contract_id,
  m.reference_blob,
  m.title,
  m.description,
  m.media,
  m.media_hash,
  m.extra,
  c.name as nft_contract_name,
  c.symbol as nft_contract_symbol,
  c.icon as nft_contract_icon,
  c.spec as nft_contract_spec,
  c.base_uri,
  c.reference as nft_contract_reference,
  c.created_at as nft_contract_created_at,
  c.owner_id as nft_contract_owner_id,
  c.is_mintbase as nft_contract_is_mintbase
from nft_metadata m left join nft_contracts c on m.nft_contract_id = c.id;

create view mb_views.nft_tokens as
select
  t.nft_contract_id,
  t.token_id,
  t.owner,
  t.mint_memo,
  t.last_transfer_timestamp,
  t.last_transfer_receipt_id,
  t.minted_timestamp,
  t.minted_receipt_id,
  t.burned_timestamp,
  t.burned_receipt_id,
  t.minter,
  -- metadata
  t.reference,
  t.reference_hash,
  t.copies,
  t.issued_at,
  t.expires_at,
  t.starts_at,
  t.updated_at,
  t.metadata_id,
  m.reference_blob,
  m.title,
  m.description,
  m.media,
  m.media_hash,
  m.extra,
  m.nft_contract_name,
  m.nft_contract_symbol,
  m.nft_contract_icon,
  m.nft_contract_spec,
  m.base_uri,
  m.nft_contract_reference,
  m.nft_contract_created_at,
  m.nft_contract_owner_id,
  m.nft_contract_is_mintbase,
  -- payouts
  t.royalties_percent,
  t.royalties,
  t.splits
from nft_tokens t left join mb_views.nft_metadata m on t.metadata_id = m.id;

-- ------------- Activity tracking: Redeeming, provenance, etc -------------- --

-- view to combine nft_activities with the metadata from nft_tokens
create view mb_views.nft_activities as
select
  a.receipt_id,
  a.tx_sender,
  a.timestamp,
  a.nft_contract_id,
  a.token_id,
  a.kind,
  a.action_sender,
  a.action_receiver,
  a.price,
  t.reference,
  t.reference_hash,
  t.copies,
  m.title,
  m.description,
  m.media,
  m.media_hash,
  m.extra
from nft_activities a
  left join nft_tokens t
    on a.nft_contract_id = t.nft_contract_id
    and a.token_id = t.token_id
  left join nft_metadata m
    on t.metadata_id = m.id;

-- ---------------------------- Mintbase market ----------------------------- --

-- Filter by unlisted, sold, or invalidation cases that the contracts cannot
-- keep track of. FIXME: this can still be wrong if the approval ID has changed.
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

-- ---------------------- misc views (helpful for FE) ----------------------- --
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

create view mb_views.top_stores as
select nft_contract_id, date, sum(amount) as total
from (
	select
	    nft_contract_id,
    	amount,
	    date_trunc('month', timestamp) as date
	from nft_earnings
) as sales
group by (date, nft_contract_id)
order by date desc, total desc;
