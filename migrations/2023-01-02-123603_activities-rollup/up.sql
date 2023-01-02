create view mb_views.nft_activities_rollup as
  select
    a.tx_sender,
    a.timestamp,
    a.nft_contract_id,
    a.kind,
    a.action_sender,
    a.action_receiver,
    a.price,
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
    		metadata_id
    ) a
    left join nft_metadata m
      on a.metadata_id = m.id;

create index nft_activities_receipt_id_index on nft_activities(receipt_id);
