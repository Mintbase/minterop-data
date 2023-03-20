drop index nft_attributes_search_index;
create index nft_attributes_search_index
on public.nft_attributes
using gin(
  nft_contract_id,
  attribute_type,
  attribute_value
);
drop extension pg_trgm;
