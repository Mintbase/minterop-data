drop view mb_views.nft_tokens_with_listing;
drop view mb_views.nft_activities_rollup;
drop view mb_views.nft_notifications;

drop view mb_views.active_listings;
drop view mb_views.active_listings_by_contract;
drop view mb_views.active_listings_rollup;
drop view mb_views.auctions_with_offer;
drop view mb_views.nft_activities;
drop view mb_views.nft_metadata_unburned;

drop view analytics_tmp.affiliate_earnings;
drop view analytics_tmp.affiliate_earnings_monthly;
drop view analytics_tmp.affiliate_earnings_yearly;

drop view mb_views.nft_listings;
drop view mb_views.nft_offers;
drop view mb_views.nft_earnings;

drop table currency_conversions;

create view mb_views.active_listings as
  select
    l.nft_contract_id,
    l.token_id,
    l.market_id,
    l.approval_id,
    l.created_at,
    l.receipt_id,
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
    m.content_flag
  from nft_listings l
    left join nft_metadata m
    on l.metadata_id = m.id
  where l.unlisted_at is null
    and l.accepted_at is null
    and l.invalidated_at is null;

create view mb_views.active_listings_rollup as
  select distinct on (metadata_id)
    l.nft_contract_id,
    l.token_id,
    l.market_id,
    l.approval_id,
    l.created_at,
    l.receipt_id,
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
    m.content_flag
  from nft_listings l
    left join nft_metadata m
    on l.metadata_id = m.id
  where l.unlisted_at is null
    and l.accepted_at is null
    and l.invalidated_at is null
  order by metadata_id, price;

create view mb_views.active_listings_by_contract as
  select
    c.id as nft_contract_id,
    c.base_uri,
    cl.price,
    cl.currency,
    cl.created_at,
    cl.metadata_id,
    cl.token_id,
    cl.market_id,
    cl.approval_id,
    cl.listed_by,
    tl.total_listings,
    cmd.title,
    cmd.media
  from nft_contracts c
  left join lateral (
    select distinct on (l.metadata_id)
      l.price,
      l.currency,
      l.created_at,
      l.token_id,
      l.metadata_id,
      l.market_id,
      l.approval_id,
      l.listed_by
    from nft_listings l
    where l.nft_contract_id = c.id and l.unlisted_at is null and l.accepted_at is null and l.invalidated_at is null
    order by l.metadata_id, l.created_at desc
    limit 3
  ) cl on true
  left join lateral (
    select count(*) as total_listings
    from nft_listings l
    where l.nft_contract_id = c.id and l.unlisted_at is null and l.accepted_at is null and l.invalidated_at is null
  ) tl on true
  left join lateral (
    select m.title, m.media -- future! select media type, other ref json fields of interest
    from nft_metadata m
    where cl.metadata_id = m.id and c.id = m.nft_contract_id
    limit 1
  ) cmd on true
  where cl.price is not null; -- omit null lateral appendages

create view mb_views.auctions_with_offer as
  select distinct on (nft_contract_id, token_id, market_id, approval_id)
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
    m.content_flag,
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

create view mb_views.nft_activities as
  select
    a.receipt_id,
    a.tx_sender,
    a.timestamp,
    a.nft_contract_id,
    a.token_id,
    a.kind,
    a.action_sender,
    a.action_receiver,
    a.price,
    a.currency,
    t.reference,
    t.reference_hash,
    t.copies,
    t.metadata_id,
    m.title,
    m.description,
    m.media,
    m.media_hash,
    m.extra,
    m.reference_blob,
    m.content_flag
  from nft_activities a
    left join nft_tokens t
      on a.nft_contract_id = t.nft_contract_id
      and a.token_id = t.token_id
    left join nft_metadata m
      on t.metadata_id = m.id;

create view mb_views.nft_activities_rollup as
  select
    a.tx_sender,
    a.timestamp,
    a.nft_contract_id,
    a.kind,
    a.action_sender,
    a.action_receiver,
    a.price,
    a.currency,
    m.reference,
    m.reference_blob,
    m.id as metadata_id,
    m.title,
    m.description,
    m.media,
    m.media_hash,
    m.extra,
    m.content_flag,
    a.receipt_id,
    a.count,
    a.token_ids
  from (
    select
	  count(*),
      tx_sender,
      timestamp,
	  a_.nft_contract_id,
      kind,
	  action_sender,
      action_receiver,
      price,
      currency,
      receipt_id,
      metadata_id,
      array_agg(a_.token_id) token_ids
    from (
      select
    	a__.nft_contract_id,
        a__.token_id,
        tx_sender,
        timestamp,
        kind,
        action_sender,
        action_receiver,
        price,
        currency,
        receipt_id,
        metadata_id
      from nft_activities a__
      left join nft_tokens t
      on a__.nft_contract_id = t.nft_contract_id and a__.token_id = t.token_id
    ) a_
    group by
      receipt_id,
      tx_sender,
      timestamp,
      nft_contract_id,
      kind,
      action_sender,
      action_receiver,
      price,
      currency,
      metadata_id
  ) a
  left join nft_metadata m
  on a.metadata_id = m.id;

create view mb_views.nft_metadata_unburned as
  select md.id as metadata_id,
    md.title,
    md.description,
    md.reference,
    md.media,
    md.nft_contract_id,
    md.base_uri,
    md.reference_blob,
    md.content_flag,
    t.minted_timestamp,
    t.last_transfer_timestamp,
    t.minter,
    l.price,
    l.currency,
    l.listed_by
  from nft_metadata md
  left join lateral (
    select
      t.minted_timestamp,
      t.last_transfer_timestamp,
      t.minter
    from nft_tokens t
    where
      t.burned_timestamp is null and t.metadata_id = md.id
    order by greatest(t.minted_timestamp, t.last_transfer_timestamp) desc
    limit 1
  ) t on true
  left join lateral (
    select
      p.price,
      p.currency,
      p.listed_by
    from nft_listings p
    where
      p.unlisted_at is null and
      p.accepted_at is null and
      p.invalidated_at is null and
      p.metadata_id = md.id
    order by p.price asc
    limit 1
  ) l on true
  where coalesce(t.last_transfer_timestamp, t.minted_timestamp) is not null;

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

create view mb_views.nft_tokens_with_listing as
  select
    t.nft_contract_id,
    t.token_id,
    t.owner,
    t.metadata_id,
    l.price,
    l.currency,
    l.reference_blob,
    l.content_flag
  from nft_tokens t
  left join mb_views.active_listings l
    on l.nft_contract_id = t.nft_contract_id
    and l.token_id = t.token_id
  where t.burned_timestamp is null;

create view analytics_tmp.affiliate_earnings as
  select
    receiver_id as affiliate_id,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
	select receiver_id, amount
    from nft_earnings
    where is_affiliate = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by receiver_id
  order by receiver_id;

create view analytics_tmp.affiliate_earnings_monthly as
  select
    date_trunc,
    receiver_id as affiliate_id,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
    select
      to_date(to_char(timestamp, 'YYYY-MM'), 'YYYY-MM') as date_trunc,
      receiver_id,
      amount
    from nft_earnings
    where is_affiliate = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by date_trunc, receiver_id
  order by date_trunc, receiver_id;

create view analytics_tmp.affiliate_earnings_yearly as
  select
    date_trunc,
    receiver_id as affiliate_id,
    sum(amount) as total_earned,
    count(*) as sales_count
  from (
    select
      to_date(to_char(timestamp, 'YYYY'), 'YYYY') as date_trunc,
      receiver_id,
      amount
    from nft_earnings
    where is_affiliate = TRUE
      and nft_contract_id <> 'deadmau5.mintbase1.near'
  ) e
  group by date_trunc, receiver_id
  order by date_trunc, receiver_id;
