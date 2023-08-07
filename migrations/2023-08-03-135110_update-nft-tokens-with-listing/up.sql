drop view mb_views.nft_tokens_with_listing;
create view mb_views.nft_tokens_with_listing as
  select
    t.nft_contract_id,
    t.token_id,
    t.owner,
    t.metadata_id,
    t.minted_timestamp,
    t.last_transfer_timestamp,
    l.price,
    l.currency,
    l.market_id,
    l.kind as listing_kind,
    m.reference_blob,
    m.content_flag,
    m.title,
    m.description
  from nft_tokens t
  left join (
    select * from nft_listings
    where unlisted_at is null and invalidated_at is null and accepted_at is null
    order by created_at desc
  ) l
    on l.nft_contract_id = t.nft_contract_id
    and l.token_id = t.token_id
  left join nft_metadata m
    on t.metadata_id = m.id
  where t.burned_timestamp is null
  order by price desc nulls last;
