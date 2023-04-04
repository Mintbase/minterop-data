create table nft_external_listings (
  nft_contract_id text not null,
  token_id text not null,
  market_id text not null,
  approval_id numeric not null,
  lister_id text not null,
  listing_price numeric,
  listed_at timestamp,
  listing_receipt_id text,
  buyer_id text,
  sale_price numeric,
  sold_at timestamp,
  sale_receipt_id text,
  primary key (nft_contract_id, token_id, market_id, approval_id)
);
