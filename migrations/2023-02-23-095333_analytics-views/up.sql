-- TODO:
-- [x] daily stats (all-MB)
-- [ ] daily stats per contract
-- [ ] weekly stats
-- [ ] monthly stats
-- [ ] referrer earnings
-- [ ] new analytics schema
-- [ ] cronjob
-- [ ] redo analytics service

create materialized view analytics_tmp.daily_stats as
select *, to_date(year_month_day, 'YYYY-MM-DD')::timestamp as date_trunc from (
  select
    coalesce(
      minted.year_month_day,
      transferred.year_month_day,
      burned.year_month_day,
      listed.year_month_day,
      sold.year_month_day,
      deployed.year_month_day,
      unique_ids.year_month_day
    ) as year_month_day,
    minted.mints_count,
    minted.minters_count,
    minted.minted_contracts_count,
    minted.total_minted,
    transferred.transfers_count,
    transferred.senders_count,
    transferred.receivers_count,
    transferred.transferred_contracts_count,
    transferred.total_transferred,
    burned.burns_count,
    burned.burners_count,
    burned.burned_contracts_count,
    burned.total_burned,
    listed.lists_count,
    listed.listers_count,
    listed.listed_contracts_count,
    listed.total_listed,
    sold.sales_count,
    sold.buyers_count,
    sold.sellers_count,
    sold.sold_contracts_count,
    sold.total_sold,
    deployed.deploys_count,
    deployed.deployers_count,
    deployed.total_deployed,
    unique_ids.activities_count,
    unique_ids.unique_account_ids,
    unique_ids.unique_token_ids,
    unique_ids.unique_contract_ids
  -- minted tokens
  from (
    select
      year_month_day,
      count(*) as mints_count,
      count(distinct(minter)) as minters_count,
      count(distinct(nft_contract_id)) as minted_contracts_count,
      sum(count(*)) over (order by year_month_day) as total_minted
    from (
      select
        to_char(minted_timestamp, 'YYYY-MM-DD') as year_month_day,
        minter,
        nft_contract_id
      from nft_tokens
      where nft_contract_id like '%.mintbase1.near'
        and nft_contract_id <> 'deadmau5.mintbase1.near'
        and minted_timestamp is not null
    ) t
    where year_month_day is not null
    group by year_month_day
  ) minted
  -- transferred tokens
  full outer join (
    select
      year_month_day,
      count(*) as transfers_count,
      count(distinct(action_sender)) as senders_count,
      count(distinct(action_receiver)) as receivers_count,
      count(distinct(nft_contract_id)) as transferred_contracts_count,
      sum(count(*)) over (order by year_month_day) as total_transferred
    from (
      select
        to_char(timestamp, 'YYYY-MM-DD') as year_month_day,
        action_sender,
        action_receiver,
        nft_contract_id
      from nft_activities
      where kind = 'transfer'
        and nft_contract_id like '%.mintbase1.near'
        and nft_contract_id <> 'deadmau5.mintbase1.near'
    ) t
    group by year_month_day
  ) transferred
  on minted.year_month_day = transferred.year_month_day
  -- burned tokens
  full outer join (
    select
      year_month_day,
      count(*) as burns_count,
      count(distinct(owner)) as burners_count,
      count(distinct(nft_contract_id)) as burned_contracts_count,
      sum(count(*)) over (order by year_month_day) as total_burned
    from (
      select
        to_char(burned_timestamp, 'YYYY-MM-DD') as year_month_day,
        owner,
        nft_contract_id
      from nft_tokens
      where nft_contract_id like '%.mintbase1.near'
        and nft_contract_id <> 'deadmau5.mintbase1.near'
        and burned_timestamp is not null
    ) t
    group by year_month_day
  ) burned
  on coalesce(
    minted.year_month_day, transferred.year_month_day
  ) = burned.year_month_day
  -- listed tokens
  full outer join (
    select
      year_month_day,
      count(*) as lists_count,
      count(distinct(listed_by)) as listers_count,
      count(distinct(nft_contract_id)) as listed_contracts_count,
      sum(count(*)) over (order by year_month_day) as total_listed
    from (
      select
        to_char(created_at, 'YYYY-MM-DD') as year_month_day,
        listed_by,
        nft_contract_id
      from nft_listings
    ) t
    group by year_month_day
  ) listed
  on coalesce(
    minted.year_month_day, transferred.year_month_day, burned.year_month_day
  ) = listed.year_month_day
  -- sold tokens
  full outer join (
    select
      year_month_day,
      count(*) as sales_count,
      count(distinct(offered_by)) as buyers_count,
      count(distinct(listed_by)) as sellers_count,
      count(distinct(nft_contract_id)) as sold_contracts_count,
      sum(count(*)) over (order by year_month_day) as total_sold
    from (
      select
        to_char(l.accepted_at, 'YYYY-MM-DD') as year_month_day,
        listed_by,
        offered_by,
        l.nft_contract_id
      from ( select * from nft_offers where accepted_at is not null ) o
      left join ( select * from nft_listings where accepted_at is not null ) l
      on o.nft_contract_id = l.nft_contract_id
        and o.token_id = l.token_id
        and o.market_id = l.market_id
        and o.approval_id = o.approval_id
        and o.offer_id = l.accepted_offer_id
    ) t
    where year_month_day is not null
    group by year_month_day
  ) sold
  on coalesce(
    minted.year_month_day,
    transferred.year_month_day,
    burned.year_month_day,
    listed.year_month_day
  ) = sold.year_month_day
  -- deployed contracts
  full outer join (
    select
      year_month_day,
      to_date(year_month_day, 'YYYY-MM-DD') as created_at,
      count(*) as deploys_count,
      count(distinct(owner_id)) as deployers_count,
      sum(count(*)) over (order by year_month_day) as total_deployed
    from (
      select
        to_char(created_at, 'YYYY-MM-DD') as year_month_day,
        id,
        owner_id
      from nft_contracts
      where id like '%.mintbase1.near'
        and created_at is not null
    ) t
    group by year_month_day
  ) deployed
  on coalesce(
    minted.year_month_day,
    transferred.year_month_day,
    burned.year_month_day,
    listed.year_month_day,
    sold.year_month_day
  ) = deployed.year_month_day
  -- Unique account/token/contract IDs
  full outer join (
    select
      year_month_day,
      count(*) as activities_count,
      count(distinct(action_sender)) as unique_account_ids,
      count(distinct(token_id)) as unique_token_ids,
      count(distinct(nft_contract_id)) as unique_contract_ids
    from (
      select
        to_char(timestamp, 'YYYY-MM-DD') as year_month_day,
        action_sender,
        token_id,
        nft_contract_id
      from nft_activities
      where nft_contract_id like '%.mintbase1.near'
      and nft_contract_id <> 'deadmau5.mintbase1.near'
    ) t
    group by year_month_day
  ) unique_ids
  on coalesce(
    minted.year_month_day,
    transferred.year_month_day,
    burned.year_month_day,
    listed.year_month_day,
    sold.year_month_day,
    deployed.year_month_day
  ) = unique_ids.year_month_day
) t
order by year_month_day desc;

-- TODO: daily_stats_per_contract
-- TODO: weekly_stats
-- TODO: weekly_stats_per_contract
-- TODO: monthly_stats
-- TODO: monthly_stats_per_contract

-- -------------------------------- template -------------------------------- --
create materialized view analytics_tmp.daily_stats as
select
  coalesce(minted.year_month_day, listed.year_month_day) as year_month_day,
  to_date(coalesce(minted.year_month_day, listed.year_month_day), 'YYYY-MM-DD')::timestamp as date_trunc,
  minted.mints_count,
  minted.minters_count,
  minted.contracts_count as minted_contracts_count,
  -- TODO: transferred
  -- TODO: burned
  listed.lists_count,
  listed.listers_count,
  listed.contracts_count as listed_contracts_count
  -- TODO: sold
  -- TODO: mb_stores
  -- TODO: mb_tokens
  -- TODO: unique_account_ids
  -- TODO: cumulative
from (
  select
    year_month_day,
    count(*) as mints_count,
    count(distinct(minter)) as minters_count,
    count(distinct(nft_contract_id)) as contracts_count
  from (
    select
      to_char(minted_timestamp, 'YYYY-MM-DD') as year_month_day,
      minter,
      nft_contract_id
    from nft_tokens
    where nft_contract_id like '%.mintbase1.near'
      and nft_contract_id <> 'deadmau5.mintbase1.near'
      and minted_timestamp is not null
  ) t
  where year_month_day is not null
  group by year_month_day
  order by year_month_day desc
) minted
-- TODO: transferred
-- TODO: burned
full outer join (
  select
    year_month_day,
    count(*) as lists_count,
    count(distinct(listed_by)) as listers_count,
    count(distinct(nft_contract_id)) as contracts_count
  from (
    select
      to_char(created_at, 'YYYY-MM-DD') as year_month_day,
      listed_by,
      nft_contract_id
    from nft_listings
  ) t
  group by year_month_day
  order by year_month_day
) listed
on minted.year_month_day = listed.year_month_day
-- TODO: sold
-- TODO: mb_stores
-- TODO: mb_tokens
-- TODO: unique_account_ids
-- TODO: cumulative
-- unfortunately, these filters only work here
order by minted.year_month_day desc;
