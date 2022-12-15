drop view mb_views.nft_owned_tokens;
create view mb_views.nft_owned_tokens as
  select * from (
    select * from mb_views.nft_tokens
    where burned_timestamp is null
    order by greatest(last_transfer_timestamp, minted_timestamp) desc nulls last
  ) t
  left join lateral (
    select
      price,
      currency,
      kind as listing_kind,
      market_id,
      approval_id as listing_approval_id
    from nft_listings l
    where
      l.unlisted_at is null and
      l.accepted_at is null and
      l.invalidated_at is null and
      l.nft_contract_id = t.nft_contract_id and
      l.token_id = t.token_id
    order by l.price asc
    limit 1
  ) l on true;
