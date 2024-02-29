alter table nft_metadata
  add royalties          jsonb,
  add max_supply         numeric,
  add last_possible_mint numeric,
  add is_locked          boolean;
