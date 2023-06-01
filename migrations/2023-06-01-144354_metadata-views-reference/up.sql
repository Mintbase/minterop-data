drop view mb_views.nft_metadata_unburned;
drop view mb_views.nft_metadata;

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

create view mb_views.nft_metadata as
  select
    m.id,
    m.nft_contract_id,
    m.reference_blob,
    m.title,
    m.description,
    m.reference,
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
