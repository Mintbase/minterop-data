create extension if not exists btree_gin;

create index nft_attributes_search_index
on nft_attributes
using gin(nft_contract_id, attribute_type, attribute_value);
