create extension if not exists pg_trgm;
drop index nft_attributes_search_index;
create index nft_attributes_search_index
on public.nft_attributes
using gin(
  nft_contract_id gin_trgm_ops,
  attribute_type gin_trgm_ops,
  attribute_value gin_trgm_ops
);
