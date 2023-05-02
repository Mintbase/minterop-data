drop view mb_views.nft_metadata_unburned;
create view mb_views.nft_metadata_unburned as
select md.id as metadata_id,
  md.title,
  md.description,
  md.media,
  md.nft_contract_id,
  md.base_uri,
  md.reference_blob,
  md.content_flag,
  t.minted_timestamp,
  t.last_transfer_timestamp,
  t.minter,
  l.price,
  l.currency
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
  select p.price
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

drop view mb_views.nft_activities_rollup;
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

drop view mb_views.nft_tokens_with_listing;
create view mb_views.nft_tokens_with_listing
as select
	t.nft_contract_id,
	t.token_id,
	t.owner,
	t.metadata_id,
	l.price,
	l.currency,
  l.reference_blob
from nft_tokens t
left join mb_views.active_listings l
  on l.nft_contract_id = t.nft_contract_id
  and l.token_id = t.token_id
where t.burned_timestamp is null;
