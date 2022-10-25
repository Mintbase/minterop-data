create view mb_views.auctions_with_offer
as select distinct on (nft_contract_id, token_id, market_id, approval_id)
  l.nft_contract_id,
  l.token_id,
  l.market_id,
  l.approval_id,
  l.created_at,
  l.receipt_id as listing_receipt_id,
  l.kind,
  l.price,
  l.currency,
  l.listed_by,
  l.metadata_id,
  m.reference,
  m.minter,
  m.title,
  m.description,
  m.reference_blob,
  m.media,
  m.extra,
  m.base_uri,
  -- offer
  o.offered_by,
  o.offer_price,
  o.offered_at,
  o.receipt_id as offer_receipt_id,
  o.expires_at as offer_expires_at,
  o.offer_id,
  o.withdrawn_at as offer_withdrawn_at,
  o.accepted_at as offer_accepted_at
from nft_listings l
  left join nft_metadata m
  on l.metadata_id = m.id
  left join (
  	select * from nft_offers
  	where withdrawn_at is null
  ) o
    on l.nft_contract_id = o.nft_contract_id
    and l.token_id = o.token_id
    and l.market_id = o.market_id
    and l.approval_id = o.approval_id
where l.kind = 'auction'
order by nft_contract_id, token_id, market_id, approval_id, o.offered_at desc;
