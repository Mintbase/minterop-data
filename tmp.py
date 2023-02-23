def json_agg(sql: str) -> str:
    return f"""select json_agg(to_json(d)) from ({sql}) as d;"""


MINTBASE_CONTRACTS = """
nft_contract_id like '%.mintbase1.near'
and nft_contract_id <> 'deadmau5.mintbase1.near'
""".strip()

MINTBASE_TOKENS = f"{MINTBASE_CONTRACTS} and minted_timestamp is not null"

OFFERS_LISTINGS_JOIN = """
( select * from nft_offers where accepted_at is not null ) o
left join ( select * from nft_listings where accepted_at is not null ) l
on o.nft_contract_id = l.nft_contract_id
  and o.token_id = l.token_id
  and o.market_id = l.market_id
  and o.approval_id = o.approval_id
  and o.offer_id = l.accepted_offer_id
""".strip()

# ---------------------------------- minted ---------------------------------- #
MINTED_DAILY_FILTERED_SQL = f"""
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
  where minted_timestamp::date >= '{{0}}'::date
    and minted_timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_month_day
order by year_month_day
""".strip()

MINTED_WEEKLY_SQL = f"""
select
  year_week,
  count(*) as mints_count,
  count(distinct(minter)) as minters_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(minted_timestamp, 'YYYY-WW') as year_week,
    minter,
    nft_contract_id
  from nft_tokens
  where minted_timestamp::date >= '{{0}}'::date
    and minted_timestamp::date <= '{{1}}'::date
    and {MINTBASE_TOKENS}
) t
group by year_week
order by year_week
""".strip()

MINTED_WEEKLY_FILTERED_SQL = f"""
select
  year_week,
  count(*) as mints_count,
  count(distinct(minter)) as minters_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(minted_timestamp, 'YYYY-WW') as year_week,
    minter,
    nft_contract_id
  from nft_tokens
  where minted_timestamp::date >= '{{0}}'::date
    and minted_timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_week
order by year_week
""".strip()

MINTED_MONTHLY_SQL = f"""
select
  year_month,
  count(*) as mints_count,
  count(distinct(minter)) as minters_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(minted_timestamp, 'YYYY-MM') as year_month,
    minter,
    nft_contract_id
  from nft_tokens
  where minted_timestamp::date >= '{{0}}'::date
    and minted_timestamp::date <= '{{1}}'::date
    and {MINTBASE_TOKENS}
) t
group by year_month
order by year_month
""".strip()

MINTED_MONTHLY_FILTERED_SQL = f"""
select
  year_month,
  count(*) as mints_count,
  count(distinct(minter)) as minters_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(minted_timestamp, 'YYYY-MM') as year_month,
    minter,
    nft_contract_id
  from nft_tokens
  where minted_timestamp::date >= '{{0}}'::date
    and minted_timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_month
order by year_month
""".strip()

# ------------------------------- transferred -------------------------------- #
TRANSFERRED_DAILY_FILTERED_SQL = f"""
select
  year_month_day,
  count(*) as transfers_count,
  count(distinct(action_sender)) as senders_count,
  count(distinct(action_receiver)) as receivers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(timestamp, 'YYYY-MM-DD') as year_month_day,
    action_sender,
    action_receiver,
    nft_contract_id
  from nft_activities
  where timestamp::date >= '{{0}}'::date
    and timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_month_day
order by year_month_day
""".strip()

TRANSFERRED_WEEKLY_SQL = f"""
select
  year_week,
  count(*) as transfers_count,
  count(distinct(action_sender)) as senders_count,
  count(distinct(action_receiver)) as receivers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(timestamp, 'YYYY-WW') as year_week,
    action_sender,
    action_receiver,
    nft_contract_id
  from nft_activities
  where timestamp::date >= '{{0}}'::date
    and timestamp::date <= '{{1}}'::date
    and {MINTBASE_CONTRACTS}
) t
group by year_week
order by year_week
""".strip()

TRANSFERRED_WEEKLY_FILTERED_SQL = f"""
select
  year_week,
  count(*) as transfers_count,
  count(distinct(action_sender)) as senders_count,
  count(distinct(action_receiver)) as receivers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(timestamp, 'YYYY-WW') as year_week,
    action_sender,
    action_receiver,
    nft_contract_id
  from nft_activities
  where timestamp::date >= '{{0}}'::date
    and timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_week
order by year_week
""".strip()

TRANSFERRED_MONTHLY_SQL = f"""
select
  year_month,
  count(*) as transfers_count,
  count(distinct(action_sender)) as senders_count,
  count(distinct(action_receiver)) as receivers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(timestamp, 'YYYY-MM') as year_month,
    action_sender,
    action_receiver,
    nft_contract_id
  from nft_activities
  where timestamp::date >= '{{0}}'::date
    and timestamp::date <= '{{1}}'::date
    and {MINTBASE_CONTRACTS}
) t
group by year_month
order by year_month
""".strip()

TRANSFERRED_MONTHLY_FILTERED_SQL = f"""
select
  year_month,
  count(*) as transfers_count,
  count(distinct(action_sender)) as senders_count,
  count(distinct(action_receiver)) as receivers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(timestamp, 'YYYY-MM') as year_month,
    action_sender,
    action_receiver,
    nft_contract_id
  from nft_activities
  where timestamp::date >= '{{0}}'::date
    and timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_month
order by year_month
""".strip()


# ---------------------------------- burned ---------------------------------- #
BURNED_DAILY_FILTERED_SQL = f"""
select
  year_month_day,
  count(*) as burns_count,
  count(distinct(owner)) as burners_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(burned_timestamp, 'YYYY-MM-DD') as year_month_day,
    owner,
    nft_contract_id
  from nft_tokens
  where burned_timestamp::date >= '{{0}}'::date
    and burned_timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_month_day
order by year_month_day
""".strip()

BURNED_WEEKLY_SQL = f"""
select
  year_week,
  count(*) as burns_count,
  count(distinct(owner)) as burners_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(burned_timestamp, 'YYYY-WW') as year_week,
    owner,
    nft_contract_id
  from nft_tokens
  where burned_timestamp::date >= '{{0}}'::date
    and burned_timestamp::date <= '{{1}}'::date
    and {MINTBASE_TOKENS}
) t
group by year_week
order by year_week
""".strip()

BURNED_WEEKLY_FILTERED_SQL = f"""
select
  year_week,
  count(*) as burns_count,
  count(distinct(owner)) as burners_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(burned_timestamp, 'YYYY-WW') as year_week,
    owner,
    nft_contract_id
  from nft_tokens
  where burned_timestamp::date >= '{{0}}'::date
    and burned_timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_week
order by year_week
""".strip()

BURNED_MONTHLY_SQL = f"""
select
  year_month,
  count(*) as burns_count,
  count(distinct(owner)) as burners_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(burned_timestamp, 'YYYY-MM') as year_month,
    owner,
    nft_contract_id
  from nft_tokens
  where burned_timestamp::date >= '{{0}}'::date
    and burned_timestamp::date <= '{{1}}'::date
    and {MINTBASE_TOKENS}
) t
group by year_month
order by year_month
""".strip()

BURNED_MONTHLY_FILTERED_SQL = f"""
select
  year_month,
  count(*) as burns_count,
  count(distinct(owner)) as burners_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(burned_timestamp, 'YYYY-MM') as year_month,
    owner,
    nft_contract_id
  from nft_tokens
  where burned_timestamp::date >= '{{0}}'::date
    and burned_timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_month
order by year_month
""".strip()

# ---------------------------------- listed ---------------------------------- #
LISTED_DAILY_FILTERED_SQL = f"""
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
  where created_at::date >= '{{0}}'::date
    and created_at::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_month_day
order by year_month_day
""".strip()

LISTED_WEEKLY_SQL = f"""
select
  year_week,
  count(*) as lists_count,
  count(distinct(listed_by)) as listers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(created_at, 'YYYY-WW') as year_week,
    listed_by,
    nft_contract_id
  from nft_listings
  where created_at::date >= '{{0}}'::date
    and created_at::date <= '{{1}}'::date
) t
group by year_week
order by year_week
""".strip()

LISTED_WEEKLY_FILTERED_SQL = f"""
select
  year_week,
  count(*) as lists_count,
  count(distinct(listed_by)) as listers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(created_at, 'YYYY-WW') as year_week,
    listed_by,
    nft_contract_id
  from nft_listings
  where created_at::date >= '{{0}}'::date
    and created_at::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_week
order by year_week
""".strip()

LISTED_MONTHLY_SQL = f"""
select
  year_month,
  count(*) as lists_count,
  count(distinct(listed_by)) as listers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(created_at, 'YYYY-MM') as year_month,
    listed_by,
    nft_contract_id
  from nft_listings
  where created_at::date >= '{{0}}'::date
    and created_at::date <= '{{1}}'::date
) t
group by year_month
order by year_month
""".strip()

LISTED_MONTHLY_FILTERED_SQL = f"""
select
  year_month,
  count(*) as lists_count,
  count(distinct(listed_by)) as listers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(created_at, 'YYYY-MM') as year_month,
    listed_by,
    nft_contract_id
  from nft_listings
  where created_at::date >= '{{0}}'::date
    and created_at::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_month
order by year_month
""".strip()

# ----------------------------------- sold ----------------------------------- #
# TODO: these are quite slow, probably due to the join, might replace with
# lateral join later

SOLD_DAILY_FILTERED_SQL = f"""
select
  year_month_day,
  count(*) as sales_count,
  count(distinct(offered_by)) as buyers_count,
  count(distinct(listed_by)) as sellers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(l.accepted_at, 'YYYY-MM-DD') as year_month_day,
    listed_by,
    offered_by,
    l.nft_contract_id
  from {OFFERS_LISTINGS_JOIN}
  where l.accepted_at::date >= '{{0}}'::date
    and l.accepted_at::date <= '{{1}}'::date
    and l.nft_contract_id = '{{2}}'
) t
group by year_month_day
order by year_month_day
""".strip()

SOLD_WEEKLY_SQL = f"""
select
  year_week,
  count(*) as sales_count,
  count(distinct(offered_by)) as buyers_count,
  count(distinct(listed_by)) as sellers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(l.accepted_at, 'YYYY-WW') as year_week,
    listed_by,
    offered_by,
    l.nft_contract_id
  from {OFFERS_LISTINGS_JOIN}
  where l.accepted_at::date >= '{{0}}'::date
    and l.accepted_at::date <= '{{1}}'::date
) t
group by year_week
order by year_week
""".strip()

SOLD_WEEKLY_FILTERED_SQL = f"""
select
  year_week,
  count(*) as sales_count,
  count(distinct(offered_by)) as buyers_count,
  count(distinct(listed_by)) as sellers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(l.accepted_at, 'YYYY-WW') as year_week,
    listed_by,
    offered_by,
    l.nft_contract_id
  from {OFFERS_LISTINGS_JOIN}
  where l.accepted_at::date >= '{{0}}'::date
    and l.accepted_at::date <= '{{1}}'::date
    and l.nft_contract_id = '{{2}}'
) t
group by year_week
order by year_week
""".strip()

SOLD_MONTHLY_SQL = f"""
select
  year_month,
  count(*) as sales_count,
  count(distinct(offered_by)) as buyers_count,
  count(distinct(listed_by)) as sellers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(l.accepted_at, 'YYYY-MM') as year_month,
    listed_by,
    offered_by,
    l.nft_contract_id
  from {OFFERS_LISTINGS_JOIN}
  where l.accepted_at::date >= '{{0}}'::date
    and l.accepted_at::date <= '{{1}}'::date
) t
group by year_month
order by year_month
""".strip()

SOLD_MONTHLY_FILTERED_SQL = f"""
select
  year_month,
  count(*) as sales_count,
  count(distinct(offered_by)) as buyers_count,
  count(distinct(listed_by)) as sellers_count,
  count(distinct(nft_contract_id)) as contracts_count
from (
  select
    to_char(l.accepted_at, 'YYYY-MM') as year_month,
    listed_by,
    offered_by,
    l.nft_contract_id
  from {OFFERS_LISTINGS_JOIN}
  where l.accepted_at::date >= '{{0}}'::date
    and l.accepted_at::date <= '{{1}}'::date
    and l.nft_contract_id = '{{2}}'
) t
group by year_month
order by year_month
""".strip()

# -------------------------------- MB stores --------------------------------- #
MB_STORES_WEEKLY_SQL = f"""
select year_week, deploys_count, deployers_count, total_deployed from (
  select
    year_week,
    to_date(year_week, 'YYYY-WW') as created_at,
    count(*) as deploys_count,
	  count(distinct(owner_id)) as deployers_count,
    sum(count(*)) over (order by year_week) as total_deployed
  from (
    select
      to_char(created_at, 'YYYY-WW') as year_week,
      id,
      owner_id
    from nft_contracts
    where id like '%.mintbase1.near'
      and created_at is not null
  ) t
  group by year_week
  order by year_week
) u
where created_at >= '{{0}}'::date
  and created_at <= '{{1}}'::date
""".strip()

MB_STORES_MONTHLY_SQL = f"""
select year_month, deploys_count, deployers_count, total_deployed from (
  select
    year_month,
    to_date(year_month, 'YYYY-MM') as created_at,
    count(*) as deploys_count,
	  count(distinct(owner_id)) as deployers_count,
    sum(count(*)) over (order by year_month) as total_deployed
  from (
    select
      to_char(created_at, 'YYYY-MM') as year_month,
      id,
      owner_id
    from nft_contracts
    where id like '%.mintbase1.near'
      and created_at is not null
  ) t
  group by year_month
  order by year_month
) u
where created_at >= '{{0}}'::date
  and created_at <= '{{1}}'::date
""".strip()

# ----------------------------- MB tokens count ------------------------------ #
MB_TOKENS_DAILY_SQL = f"""
select * from (
  select
    year_month_day,
    count(*) as mints_count,
    sum(count(*)) over (order by year_month_day) as total_minted,
    count(distinct(minter)) as minters_count,
    count(distinct(nft_contract_id)) as contracts_count
  from (
    select
      to_char(minted_timestamp, 'YYYY-MM-DD') as year_month_day,
      minter,
      nft_contract_id
    from nft_tokens
    where {MINTBASE_TOKENS}
  ) t
  group by year_month_day
  order by year_month_day
) u
where to_date(year_month_day, 'YYYY-MM-DD') >= '{{0}}'::date
  and to_date(year_month_day, 'YYYY-MM-DD') <= '{{1}}'::date
""".strip()

MB_TOKENS_DAILY_FILTERED_SQL = f"""
select * from (
  select
    year_month_day,
    count(*) as mints_count,
    sum(count(*)) over (order by year_month_day) as total_minted,
    count(distinct(minter)) as minters_count,
    count(distinct(nft_contract_id)) as contracts_count
  from (
    select
      to_char(minted_timestamp, 'YYYY-MM-DD') as year_month_day,
      minter,
      nft_contract_id
    from nft_tokens
    where nft_contract_id = '{{2}}'
  ) t
  group by year_month_day
  order by year_month_day
) u
where to_date(year_month_day, 'YYYY-MM-DD') >= '{{0}}'::date
  and to_date(year_month_day, 'YYYY-MM-DD') <= '{{1}}'::date
""".strip()

MB_TOKENS_WEEKLY_SQL = f"""
select * from (
  select
    year_week,
    count(*) as mints_count,
    sum(count(*)) over (order by year_week) as total_minted,
    count(distinct(minter)) as minters_count,
    count(distinct(nft_contract_id)) as contracts_count
  from (
    select
      to_char(minted_timestamp, 'YYYY-WW') as year_week,
      minter,
      nft_contract_id
    from nft_tokens
    where {MINTBASE_TOKENS}
  ) t
  group by year_week
  order by year_week
) u
where to_date(year_week, 'YYYY-WW') >= '{{0}}'::date
  and to_date(year_week, 'YYYY-WW') <= '{{1}}'::date
""".strip()

MB_TOKENS_WEEKLY_FILTERED_SQL = f"""
select * from (
  select
    year_week,
    count(*) as mints_count,
    sum(count(*)) over (order by year_week) as total_minted,
    count(distinct(minter)) as minters_count,
    count(distinct(nft_contract_id)) as contracts_count
  from (
    select
      to_char(minted_timestamp, 'YYYY-WW') as year_week,
      minter,
      nft_contract_id
    from nft_tokens
    where nft_contract_id = '{{2}}'
  ) t
  group by year_week
  order by year_week
) u
where to_date(year_week, 'YYYY-WW') >= '{{0}}'::date
  and to_date(year_week, 'YYYY-WW') <= '{{1}}'::date
""".strip()

MB_TOKENS_MONTHLY_SQL = f"""
select * from (
  select
    year_month,
    count(*) as mints_count,
    sum(count(*)) over (order by year_month) as total_minted,
    count(distinct(minter)) as minters_count,
    count(distinct(nft_contract_id)) as contracts_count
  from (
    select
      to_char(minted_timestamp, 'YYYY-MM') as year_month,
      minter,
      nft_contract_id
    from nft_tokens
    where {MINTBASE_TOKENS}
  ) t
  group by year_month
  order by year_month
) u
where to_date(year_month, 'YYYY-MM') >= '{{0}}'::date
  and to_date(year_month, 'YYYY-MM') <= '{{1}}'::date
""".strip()

MB_TOKENS_MONTHLY_FILTERED_SQL = f"""
select * from (
  select
    year_month,
    count(*) as mints_count,
    sum(count(*)) over (order by year_month) as total_minted,
    count(distinct(minter)) as minters_count,
    count(distinct(nft_contract_id)) as contracts_count
  from (
    select
      to_char(minted_timestamp, 'YYYY-MM') as year_month,
      minter,
      nft_contract_id
    from nft_tokens
    where nft_contract_id = '{{2}}'
  ) t
  group by year_month
  order by year_month
) u
where to_date(year_month, 'YYYY-MM') >= '{{0}}'::date
  and to_date(year_month, 'YYYY-MM') <= '{{1}}'::date
""".strip()

# ---------------------------- Affiliate earnings ---------------------------- #
AFFILIATE_EARNINGS_DAILY_SQL = f"""
select year_month_day, affiliate_id, earnings from (
  select
    year_month_day,
    to_date(year_month_day, 'YYYY-MM-DD') as timestamp,
    sum(amount) as earnings,
    receiver_id as affiliate_id
  from (
    select
      to_char(timestamp, 'YYYY-MM-DD') as year_month_day,
      amount,
      receiver_id
    from nft_earnings
    where is_affiliate = TRUE
  ) t
  group by year_month_day, affiliate_id
  order by year_month_day
) u
where timestamp >= '{{0}}'::date
  and timestamp <= '{{1}}'::date
""".strip()

AFFILIATE_EARNINGS_DAILY_FILTERED_SQL = f"""
select year_month_day, affiliate_id, earnings from (
  select
    year_month_day,
    to_date(year_month_day, 'YYYY-MM-DD') as timestamp,
    sum(amount) as earnings,
    receiver_id as affiliate_id
  from (
    select
      to_char(timestamp, 'YYYY-MM-DD') as year_month_day,
      amount,
      receiver_id
    from nft_earnings
    where is_affiliate = TRUE
      and receiver_id = '{{2}}'
  ) t
  group by year_month_day, affiliate_id
  order by year_month_day
) u
where timestamp >= '{{0}}'::date
  and timestamp <= '{{1}}'::date
""".strip()

AFFILIATE_EARNINGS_WEEKLY_SQL = f"""
select year_week, affiliate_id, earnings from (
  select
    year_week,
    to_date(year_week, 'YYYY-WW') as timestamp,
    sum(amount) as earnings,
    receiver_id as affiliate_id
  from (
    select
      to_char(timestamp, 'YYYY-WW') as year_week,
      amount,
      receiver_id
    from nft_earnings
    where is_affiliate = TRUE
  ) t
  group by year_week, affiliate_id
  order by year_week
) u
where timestamp >= '{{0}}'::date
  and timestamp <= '{{1}}'::date
""".strip()

AFFILIATE_EARNINGS_WEEKLY_FILTERED_SQL = f"""
select year_week, affiliate_id, earnings from (
  select
    year_week,
    to_date(year_week, 'YYYY-WW') as timestamp,
    sum(amount) as earnings,
    receiver_id as affiliate_id
  from (
    select
      to_char(timestamp, 'YYYY-WW') as year_week,
      amount,
      receiver_id
    from nft_earnings
    where is_affiliate = TRUE
      and receiver_id = '{{2}}'
  ) t
  group by year_week, affiliate_id
  order by year_week
) u
where timestamp >= '{{0}}'::date
  and timestamp <= '{{1}}'::date
""".strip()

AFFILIATE_EARNINGS_MONTHLY_SQL = f"""
select year_month, affiliate_id, earnings from (
  select
    year_month,
    to_date(year_month, 'YYYY-MM') as timestamp,
    sum(amount) as earnings,
    receiver_id as affiliate_id
  from (
    select
      to_char(timestamp, 'YYYY-MM') as year_month,
      amount,
      receiver_id
    from nft_earnings
    where is_affiliate = TRUE
  ) t
  group by year_month, affiliate_id
  order by year_month
) u
where timestamp >= '{{0}}'::date
  and timestamp <= '{{1}}'::date
""".strip()

AFFILIATE_EARNINGS_MONTHLY_FILTERED_SQL = f"""
select year_month, affiliate_id, earnings from (
  select
    year_month,
    to_date(year_month, 'YYYY-MM') as timestamp,
    sum(amount) as earnings,
    receiver_id as affiliate_id
  from (
    select
      to_char(timestamp, 'YYYY-MM') as year_month,
      amount,
      receiver_id
    from nft_earnings
    where is_affiliate = TRUE
      and receiver_id = '{{2}}'
  ) t
  group by year_month, affiliate_id
  order by year_month
) u
where timestamp >= '{{0}}'::date
  and timestamp <= '{{1}}'::date
""".strip()

# ---------------------------- unique account IDs ---------------------------- #
UNIQUE_ACCOUNT_IDS_DAILY_SQL = f"""
select
  year_month_day,
  count(*) as interactions_count,
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
  where timestamp::date >= '{{0}}'::date
    and timestamp::date <= '{{1}}'::date
    and {MINTBASE_CONTRACTS}
) t
group by year_month_day
order by year_month_day
""".strip()

UNIQUE_ACCOUNT_IDS_DAILY_FILTERED_SQL = f"""
select
  year_month_day,
  count(*) as interactions_count,
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
  where timestamp::date >= '{{0}}'::date
    and timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_month_day
order by year_month_day
""".strip()

UNIQUE_ACCOUNT_IDS_WEEKLY_SQL = f"""
select
  year_week,
  count(*) as interactions_count,
  count(distinct(action_sender)) as unique_account_ids,
  count(distinct(token_id)) as unique_token_ids,
  count(distinct(nft_contract_id)) as unique_contract_ids
from (
  select
    to_char(timestamp, 'YYYY-WW') as year_week,
    action_sender,
    token_id,
    nft_contract_id
  from nft_activities
  where timestamp::date >= '{{0}}'::date
    and timestamp::date <= '{{1}}'::date
    and {MINTBASE_CONTRACTS}
) t
group by year_week
order by year_week
""".strip()

UNIQUE_ACCOUNT_IDS_WEEKLY_FILTERED_SQL = f"""
select
  year_week,
  count(*) as interactions_count,
  count(distinct(action_sender)) as unique_account_ids,
  count(distinct(token_id)) as unique_token_ids,
  count(distinct(nft_contract_id)) as unique_contract_ids
from (
  select
    to_char(timestamp, 'YYYY-WW') as year_week,
    action_sender,
    token_id,
    nft_contract_id
  from nft_activities
  where timestamp::date >= '{{0}}'::date
    and timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_week
order by year_week
""".strip()

UNIQUE_ACCOUNT_IDS_MONTHLY_SQL = f"""
select
  year_month,
  count(*) as interactions_count,
  count(distinct(action_sender)) as unique_account_ids,
  count(distinct(token_id)) as unique_token_ids,
  count(distinct(nft_contract_id)) as unique_contract_ids
from (
  select
    to_char(timestamp, 'YYYY-MM') as year_month,
    action_sender,
    token_id,
    nft_contract_id
  from nft_activities
  where timestamp::date >= '{{0}}'::date
    and timestamp::date <= '{{1}}'::date
    and {MINTBASE_CONTRACTS}
) t
group by year_month
order by year_month
""".strip()

UNIQUE_ACCOUNT_IDS_MONTHLY_FILTERED_SQL = f"""
select
  year_month,
  count(*) as interactions_count,
  count(distinct(action_sender)) as unique_account_ids,
  count(distinct(token_id)) as unique_token_ids,
  count(distinct(nft_contract_id)) as unique_contract_ids
from (
  select
    to_char(timestamp, 'YYYY-MM') as year_month,
    action_sender,
    token_id,
    nft_contract_id
  from nft_activities
  where timestamp::date >= '{{0}}'::date
    and timestamp::date <= '{{1}}'::date
    and nft_contract_id = '{{2}}'
) t
group by year_month
order by year_month
""".strip()
