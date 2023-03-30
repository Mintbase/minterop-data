alter table nft_activities add column blockheight numeric;

drop view mb_views.nft_activities;
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
    a.blockheight,
    t.reference,
    t.reference_hash,
    t.copies,
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
