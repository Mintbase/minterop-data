alter table nft_metadata
  add starts_at timestamp,
  add expires_at timestamp;

update nft_metadata
  set expires_at = last_possible_mint;

alter table nft_metadata drop last_possible_mint;
