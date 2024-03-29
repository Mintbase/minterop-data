drop view mb_views.active_listings_rollup;
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
