drop view mb_views.nft_activities;
drop view mb_views.nft_metadata_unburned;
drop view mb_views.nft_tokens_with_listing;

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
  where unlisted_at is null and accepted_at is null
  order by metadata_id, price
) l on m.id=l.metadata_id;

create view mb_views.nft_tokens_with_listing as
select
	t.nft_contract_id,
	t.token_id,
	t.owner,
	t.metadata_id,
  l.reference_blob,
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
