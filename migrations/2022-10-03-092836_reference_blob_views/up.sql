drop view nft_activities;
drop view nft_metadata_unburned;
drop view nft_tokens_with_listing;

create view mb_views.nft_metadata_unburned as
select
	m.id as metadata_id,
	m.title,
	m.description,
	m.media,
  m.reference_blob,
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
  t.reference_blob,
	l.price
from nft_tokens t
left join mb_views.active_listings l on l.nft_contract_id=t.nft_contract_id
where t.burned_timestamp is null;

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
  m.extra,
  m.reference_blob
from nft_activities a
  left join nft_tokens t
    on a.nft_contract_id = t.nft_contract_id
    and a.token_id = t.token_id
  left join nft_metadata m
    on t.metadata_id = m.id;
