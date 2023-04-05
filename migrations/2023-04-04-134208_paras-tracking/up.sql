create table nft_external_listings (
  nft_contract_id text not null,
  token_id text not null,
  market_id text not null,
  approval_id numeric not null,
  lister_id text not null,
  listing_price numeric not null,
  listed_at timestamp not null,
  listing_receipt_id text not null,
  buyer_id text,
  sale_price numeric,
  sold_at timestamp,
  sale_receipt_id text,
  deleted_at timestamp,
  deletion_receipt_id text,
  failed_at timestamp,
  failure_receipt_id text,
  primary key (nft_contract_id, token_id, market_id, approval_id)
);
