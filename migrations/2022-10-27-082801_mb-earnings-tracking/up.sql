alter table nft_earnings
add column is_mintbase_cut
boolean not null default 'f';

-- needs to be dropped to alter nft_offers.referral_amount
drop view mb_views.auctions_with_offer;
alter table nft_offers
alter column referral_amount
type numeric
using referral_amount::numeric;

-- recreate
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
  l.unlisted_at,
  l.accepted_at as listing_accepted_at,
  l.invalidated_at as listing_invalidated_at,
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
      and outbid_at is null
      and invalidated_at is null
  ) o
    on l.nft_contract_id = o.nft_contract_id
    and l.token_id = o.token_id
    and l.market_id = o.market_id
    and l.approval_id = o.approval_id
where l.kind = 'auction'
order by nft_contract_id, token_id, market_id, approval_id, o.offered_at desc;

-- change nft-earnings-pkey
alter table nft_earnings drop constraint nft_earnings_pkey;
alter table nft_earnings alter is_referral set not null;
alter table nft_earnings alter is_mintbase_cut set not null;
alter table nft_earnings add primary key (
  nft_contract_id,
  token_id,
  market_id,
  approval_id,
  receiver_id,
  is_referral,
  is_mintbase_cut
);

insert into nft_earnings (
  nft_contract_id,
  token_id,
  market_id,
  approval_id,
  offer_id,
  receipt_id,
  timestamp,
  receiver_id,
  currency,
  amount,
  is_referral,
  is_mintbase_cut
) select
    nft_contract_id,
    token_id,
    market_id,
    approval_id,
    offer_id,
    receipt_id,
    accepted_at,
    market_id,  --receiver_id
    currency,
    (offer_price * 250 / 10000), -- amount
    'f', -- is_referral
    't' -- is_mintbase_cut
from nft_offers
where accepted_at is not null;

-- fix mb_views.tokens_with_listing.reference_blob
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
left join mb_views.active_listings l on l.nft_contract_id=t.nft_contract_id
where t.burned_timestamp is null;
