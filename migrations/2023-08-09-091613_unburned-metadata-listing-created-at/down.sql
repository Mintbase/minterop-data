drop view mb_views.nft_metadata_unburned;

create view mb_views.nft_metadata_unburned as
  select md.id as metadata_id,
    md.title,
    md.description,
    md.reference,
    md.media,
    md.nft_contract_id,
    md.base_uri,
    md.reference_blob,
    md.content_flag,
    t.minted_timestamp,
    t.last_transfer_timestamp,
    t.minter,
    l.price,
    l.currency,
    l.listed_by
  from nft_metadata md
  left join lateral (
    select
      t.minted_timestamp,
      t.last_transfer_timestamp,
      t.minter
    from nft_tokens t
    where
      t.burned_timestamp is null and t.metadata_id = md.id
    order by greatest(t.minted_timestamp, t.last_transfer_timestamp) desc
    limit 1
  ) t on true
  left join lateral (
    select
      p.price,
      p.currency,
      p.listed_by
    from nft_listings p
    where
      p.unlisted_at is null and
      p.accepted_at is null and
      p.invalidated_at is null and
      p.metadata_id = md.id
    order by p.price asc
    limit 1
  ) l on true
  where coalesce(t.last_transfer_timestamp, t.minted_timestamp) is not null;
