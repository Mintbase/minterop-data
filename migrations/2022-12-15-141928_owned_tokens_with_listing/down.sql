drop view mb_views.nft_owned_tokens;
create view mb_views.nft_owned_tokens as
  select * from mb_views.nft_tokens
  where burned_timestamp is null
  order by greatest(last_transfer_timestamp, minted_timestamp) desc nulls last;
