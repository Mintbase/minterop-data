alter table nft_earnings
add column is_mintbase_cut
boolean not null default 'f';

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
