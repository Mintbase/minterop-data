drop view mb_views.nft_tokens_with_listing;
create view mb_views.nft_tokens_with_listing
as select
	t.nft_contract_id,
	t.token_id,
	t.owner,
	t.metadata_id,
	l.price,
  l.reference_blob
from nft_tokens t
left join mb_views.active_listings l
  on l.nft_contract_id = t.nft_contract_id
  and l.token_id = t.token_id
where t.burned_timestamp is null;
