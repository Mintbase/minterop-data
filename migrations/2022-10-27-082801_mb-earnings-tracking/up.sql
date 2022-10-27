alter table nft_earnings
add column is_mintbase_cut
boolean not null default 'f';
