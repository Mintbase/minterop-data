alter table nft_offers add column invalidated_at timestamp;
alter table nft_offers add column outbid_at timestamp;
alter table nft_listings add column invalidated_at timestamp;

-- Populating offer invalidation
update nft_offers set invalidated_at = j.timestamp
from (
  select o.accepted_at, o.withdrawn_at, a.kind, a.timestamp
  from nft_offers o inner join nft_activities a
    on o.token_id = a.token_id
    and o.nft_contract_id = a.nft_contract_id
    and o.offered_at < a.timestamp
    order by a.timestamp asc
    limit 1
) j
where (j.kind = 'transfer' or j.kind = 'burn')
  and j.accepted_at is null
  and j.withdrawn_at is null
;

-- Populating listing invalidation
update nft_listings set invalidated_at = j.timestamp
from (
  select l.accepted_at, l.unlisted_at, a.kind, a.timestamp
  from nft_listings l inner join nft_activities a
    on l.token_id = a.token_id
    and l.nft_contract_id = a.nft_contract_id
    and l.created_at < a.timestamp
    order by a.timestamp asc
    limit 1
) j
where (j.kind = 'transfer' or j.kind = 'burn')
  and j.accepted_at is null
  and j.unlisted_at is null
;
