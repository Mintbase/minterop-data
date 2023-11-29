alter table nft_metadata
  add mb_internal_id    numeric,
  add price             numeric,
  add minters_allowlist text[];
