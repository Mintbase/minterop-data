CREATE TABLE nft_attributes (
  nft_metadata_id  TEXT NOT NULL,
  nft_contract_id TEXT NOT NULL,
  attribute_type TEXT NOT NULL,
  attribute_value TEXT,
  attribute_display_type TEXT,
  primary key(nft_metadata_id, nft_contract_id, attribute_type)
)
