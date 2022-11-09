alter table nft_metadata add column content_flag text;

drop view mb_views.nft_tokens_with_media_type;
drop view mb_views.nft_tokens_with_listing;
drop view mb_views.nft_owned_tokens;
drop view mb_views.active_listings_rollup;
drop view mb_views.active_listings;
drop view mb_views.auctions_with_offer;
drop view mb_views.nft_metadata_unburned;
drop view mb_views.nft_activities;
drop view mb_views.nft_tokens;
drop view mb_views.nft_metadata;

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
    m.content_flag as metadata_content_flag,
    c.name as nft_contract_name,
    c.symbol as nft_contract_symbol,
    c.icon as nft_contract_icon,
    c.spec as nft_contract_spec,
    c.base_uri,
    c.reference as nft_contract_reference,
    c.created_at as nft_contract_created_at,
    c.owner_id as nft_contract_owner_id,
    c.is_mintbase as nft_contract_is_mintbase,
    c.content_flag as nft_contract_content_flag
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
    m.metadata_content_flag,
    m.nft_contract_name,
    m.nft_contract_symbol,
    m.nft_contract_icon,
    m.nft_contract_spec,
    m.base_uri,
    m.nft_contract_reference,
    m.nft_contract_created_at,
    m.nft_contract_owner_id,
    m.nft_contract_is_mintbase,
    m.nft_contract_content_flag,
    -- payouts
    t.royalties_percent,
    t.royalties,
    t.splits
  from nft_tokens t left join mb_views.nft_metadata m on t.metadata_id = m.id;

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
    m.reference_blob,
    m.content_flag
  from nft_activities a
    left join nft_tokens t
      on a.nft_contract_id = t.nft_contract_id
      and a.token_id = t.token_id
    left join nft_metadata m
      on t.metadata_id = m.id;

create view mb_views.nft_metadata_unburned as
  select
    m.id as metadata_id,
    m.title,
    m.description,
    m.media,
    m.nft_contract_id,
    m.base_uri,
    m.reference_blob,
    m.content_flag,
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

create view mb_views.auctions_with_offer as
  select distinct on (nft_contract_id, token_id, market_id, approval_id)
    l.nft_contract_id,
    l.token_id,
    l.market_id,
    l.approval_id,
    l.created_at,
    l.receipt_id as listing_receipt_id,
    l.kind,
    l.price,
    l.currency,
    l.listed_by,
    l.metadata_id,
    l.unlisted_at,
    l.accepted_at as listing_accepted_at,
    l.invalidated_at as listing_invalidated_at,
    m.reference,
    m.minter,
    m.title,
    m.description,
    m.reference_blob,
    m.media,
    m.extra,
    m.base_uri,
    m.content_flag,
    -- offer
    o.offered_by,
    o.offer_price,
    o.offered_at,
    o.receipt_id as offer_receipt_id,
    o.expires_at as offer_expires_at,
    o.offer_id,
    o.withdrawn_at as offer_withdrawn_at,
    o.accepted_at as offer_accepted_at
  from nft_listings l
    left join nft_metadata m
    on l.metadata_id = m.id
    left join (
      select * from nft_offers
      where withdrawn_at is null
        and outbid_at is null
        and invalidated_at is null
    ) o
      on l.nft_contract_id = o.nft_contract_id
      and l.token_id = o.token_id
      and l.market_id = o.market_id
      and l.approval_id = o.approval_id
  where l.kind = 'auction'
  order by nft_contract_id, token_id, market_id, approval_id, o.offered_at desc;

create view mb_views.active_listings as
  select
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
    m.extra,
    m.base_uri,
    m.content_flag
  from nft_listings l
    left join nft_metadata m
    on l.metadata_id = m.id
  where l.unlisted_at is null
    and l.accepted_at is null
    and l.invalidated_at is null;

create view mb_views.active_listings_rollup as
  select distinct on (metadata_id)
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
    m.extra,
    m.base_uri,
    m.content_flag
  from nft_listings l
    left join nft_metadata m
    on l.metadata_id = m.id
  where l.unlisted_at is null
    and l.accepted_at is null
    and l.invalidated_at is null
  order by metadata_id, price;

create view mb_views.nft_owned_tokens as
  select * from mb_views.nft_tokens
  where burned_timestamp is null
  order by greatest(last_transfer_timestamp, minted_timestamp) desc nulls last;


create view mb_views.nft_tokens_with_listing as
  select
    t.nft_contract_id,
    t.token_id,
    t.owner,
    t.metadata_id,
    l.price,
    l.reference_blob,
    l.content_flag
  from nft_tokens t
  left join mb_views.active_listings l
    on l.nft_contract_id = t.nft_contract_id
    and l.token_id = t.token_id
  where t.burned_timestamp is null;

create view mb_views.nft_tokens_with_media_type as
  select
    *,
    reference_blob->>'animation_url' as forever_media_url,
    reference_blob->>'animation_url_type' as forever_media_type
  from
    mb_views.nft_tokens;
