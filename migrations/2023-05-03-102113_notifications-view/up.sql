create view mb_views.nft_notifications as
  select
    timestamp,
    receipt_id,
    action_receiver as account_id,
    'offer_placed' as kind,
    nft_contract_id,
    token_id,
    action_sender as other_account_id,
    price as amount,
    currency
  from nft_activities where kind = 'make_offer'
  union all select
    timestamp,
    receipt_id,
    action_receiver as account_id,
    'token_sold' as kind,
    nft_contract_id,
    token_id,
    action_sender as other_account_id,
    price as amount,
    currency
  from nft_activities where kind = 'sale'
  union all select
    timestamp,
    receipt_id,
    action_sender as account_id,
    'offer_accepted' as kind,
    nft_contract_id,
    token_id,
    action_receiver as other_account_id,
    price as amount,
    currency
  from nft_activities where kind = 'sale'
  union all select
  	timestamp,
  	receipt_id,
  	action_receiver as account_id,
  	'token_transferred' as kind,
  	nft_contract_id,
  	token_id,
  	action_sender as other_account_id,
  	price as amount,
  	currency
  from nft_activities where kind = 'transfer'
  union all select * from (
  	select
      e.timestamp,
      e.receipt_id,
      e.receiver_id as account_id,
      'payout' as kind,
      e.nft_contract_id,
      e.token_id,
      o.offered_by as other_account_id, -- TODO: check performance hit for joining this in
      e.amount,
      e.currency
    from nft_earnings e
    left join nft_offers o
    on e.nft_contract_id = o.nft_contract_id
      and e.token_id = o.token_id
      and e.market_id = o.market_id
      and e.approval_id = o.approval_id
      and e.offer_id = o.offer_id
  ) e
  union all select
    timestamp,
    receipt_id,
    action_receiver as account_id,
    'token_minted' as kind,
    nft_contract_id,
    token_id,
    action_sender as other_account_id,
    price as amount,
    currency
  from nft_activities where kind  = 'mint' and action_sender <> action_receiver
order by timestamp desc;
