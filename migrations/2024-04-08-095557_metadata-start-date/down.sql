alter table nft_metadata add last_possible_mint timestamp;

update nft_metadata
  set last_possible_mint = expires_at;

alter table nft_metadata
  drop starts_at,
  drop expires_at;
