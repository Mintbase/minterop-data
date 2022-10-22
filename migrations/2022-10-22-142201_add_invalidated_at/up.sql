-- Adds invalidated_at to offers and listings for when transfers occur.
alter table nft_offers add column invalidated_at timestamp;
alter table nft_listings add column invalidated_at timestamp;