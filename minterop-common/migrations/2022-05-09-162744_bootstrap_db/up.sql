-- -------------------- NFT Core and Metadata standards --------------------- --

-- The tokens table keeps track of all discovered tokens on the NEAR ecosystem.
-- Discovery is driven by NEP171 events, and metadata is later added if the
-- NEP177 standard is followed.
create table nft_tokens (
  nft_contract_id          text not null    check(nft_contract_id <> ''),
  token_id                 text not null    check(token_id     <> ''),
  owner                    text not null    check(owner        <> ''),
  mint_memo                text,
  last_transfer_timestamp  timestamp,
  -- TODO: it's really hard to get tx IDs instead of receipt IDs, but would
  -- be better for linking to NEAR explorer from website
  last_transfer_receipt_id text,
  minted_timestamp         timestamp,
  minted_receipt_id        text,
  burned_timestamp         timestamp,
  burned_receipt_id        text,
  minter                   text,
  -- metadata
  reference                text,
  reference_hash           text,
  copies                   bigint, -- -> problem on multiplied mintbase tokens :(
  issued_at                timestamp,
  expires_at               timestamp,
  starts_at                timestamp,
  updated_at               timestamp,
  metadata_id              text,
  -- payouts
  royalties_percent        integer,
  royalties                jsonb,
  splits                   jsonb,
  primary key(nft_contract_id, token_id)
);

create table nft_metadata (
  id              text primary key,
  nft_contract_id text not null,
  reference_blob  jsonb,
  title           text,        -- NEP, "name" in opensea standard
  description     text,        -- NEP, opensea
  media           text,        -- NEP
  media_hash      text,        -- NEP
  reference       text,        -- NEP
  reference_hash  text,        -- NEP
  -- media_size     bigint,      --
  -- animation_url  text,        -- opensea
  -- animation_hash text,        --
  -- animation_size bigint,      --
  -- youtube_url    text,        -- opensea
  -- document_url   text,        --
  -- document_hash  text,        --
  -- external_url   text,        -- opensea
  -- category       text,        --
  -- type           text,        --
  -- visibility     text,        --
  -- media_type     text,        --
  -- animation_type text,        --
  -- tags           jsonb,       --
  extra          text         -- NEP, can hold opensea-like attributes
);

-- The contracts table keeps track of all discovered contracts on the NEAR
-- ecosystem. Discovery is driven by NEP171 events, and table insertion requires
-- metadata queryable according to NEP177
create table nft_contracts (
  id                       text primary key,
  spec                     text not null,
  name                     text not null,
  symbol                   text,
  icon                     text,
  base_uri                 text,
  reference                text,
  reference_hash           text,
  -- created_at if indexed deploy
  created_at               timestamp,
  created_receipt_id       text,
  owner_id                 text,
  is_mintbase              boolean not null
);

-- -------------------- Events not standardized, MB only -------------------- --

-- The approvals table keeps track of up-to-date approvals, where revokes will
-- lead to deletes on the table. Use `nft_activities` to get a history of
-- approvals
create table nft_approvals (
  nft_contract_id     text      not null,
  token_id            text      not null,
  approved_account_id text      not null,
  approval_id         numeric    not null,
  receipt_id          text      not null,
  timestamp           timestamp not null,
  primary key(nft_contract_id, token_id, approved_account_id)
);

-- The minters talbe keeps track of up-to-date minters on mintbase stores.
-- Like approvals, on-chain updates will cause deletes in this table.
-- History not tracked
create table mb_store_minters (
  nft_contract_id text not null,
  minter_id       text not null,
  receipt_id      text,
  timestamp       timestamp,
  primary key(nft_contract_id, minter_id)
);

-- ------------- Activity tracking: Redeeming, provenance, etc -------------- --

-- The activities table allows tracking the full history of a token. Currently
-- only NEP171 events are being tracked as activities, but market listings,
-- offers, approvals and more shenanigans are definitely possible.
create table nft_activities (
  receipt_id      text      not null,
  tx_sender       text      not null,
  sender_pk       text,
  timestamp       timestamp not null,
  nft_contract_id text      not null,
  token_id        text      not null,
  kind            text      not null,
  action_sender   text,
  action_receiver text,
  memo            text,
  price           numeric,
  primary key(receipt_id, nft_contract_id, token_id, kind)
);

-- ---------------------------- Mintbase market ----------------------------- --

-- The listings table is used to track market activity
create table nft_listings (
  nft_contract_id   text      not null,
  token_id          text      not null,
  market_id         text      not null,
  approval_id       numeric    not null,
  created_at        timestamp not null,
  receipt_id        text      not null,
  kind              text      not null,
  price             numeric,
  -- either "near" or "ft<$>{contract_id}"
  currency          text not null,
  listed_by         text not null,
  unlisted_at       timestamp,
  accepted_at       timestamp,
  accepted_offer_id bigint,
  primary key(nft_contract_id, token_id, market_id, approval_id)
);

-- The offers table keeps track of offers being made on tokens.
create table nft_offers (
  nft_contract_id text      not null,
  token_id        text      not null,
  market_id       text      not null,
  approval_id     numeric    not null,
  currency        text      not null,
  offer_price     numeric   not null,
  offered_by      text      not null,
  offered_at      timestamp not null,
  receipt_id      text      not null,
  offer_id        bigint    not null,
  referrer_id     text,
  referral_amount text,
  withdrawn_at    timestamp,
  accepted_at     timestamp,
  primary key(nft_contract_id, token_id, market_id, approval_id, offer_id)
);

create table nft_earnings (
  nft_contract_id text      not null,
  token_id        text      not null,
  market_id       text      not null,
  approval_id     numeric    not null,
  offer_id        bigint    not null,
  receipt_id      text      not null,
  timestamp       timestamp not null,
  receiver_id     text      not null,
  currency        text      not null,
  amount          numeric   not null,
  is_referral     boolean   not null,
  primary key(nft_contract_id, token_id, market_id, approval_id, receiver_id)
);

-- ---------------------------------- Misc ---------------------------------- --

-- The blocks table currently is only responsible for holding the last synced
-- block height
create table blocks (
  synced_height bigint primary key
);

insert into blocks values (0);
