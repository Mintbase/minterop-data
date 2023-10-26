drop view mb_views.active_listings_rollup;
create view mb_views.active_listings_rollup as
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
   from (
     select *
     from nft_listings
     where unlisted_at is null
       and accepted_at is null
       and invalidated_at is null
   ) l
   left join lateral (
     select *
     from nft_metadata m0
     where m0.id = l.metadata_id
     order by created_at desc nulls last
   ) m on true;
