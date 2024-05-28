create view mb_views.nft_drops as
  select
    reference_blob->>'drop_url' as drop_url,
    nft_contract_id,
    mb_internal_id as sc_metadata_id,
    id as indexer_metadata_id,
    title,
    description,
    media,
    reference,
    reference_blob,
    minter as creator,
    max_supply,
    count as minted,
    royalties,
    royalty_percent,
    price,
    minters_allowlist,
    unique_minters,
    starts_at,
    expires_at
  from (select * from nft_metadata where reference_blob->>'drop_url' is not null) m
  left join (select metadata_id, count(*) from nft_tokens group by metadata_id) t
  on t.metadata_id = m.id;
