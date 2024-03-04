alter table nft_metadata
  add royalties          jsonb,
  add royalty_percent    numeric,
  add max_supply         numeric,
  add last_possible_mint timestamp,
  add is_locked          boolean;
