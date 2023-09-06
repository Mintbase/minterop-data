table! {
    blocks (synced_height) {
        synced_height -> Int8,
    }
}

table! {
    ft_activities (receipt_id, ft_contract_id, kind) {
        receipt_id -> Text,
        timestamp -> Timestamp,
        ft_contract_id -> Text,
        kind -> Text,
        action_sender -> Nullable<Text>,
        action_receiver -> Nullable<Text>,
        memo -> Nullable<Text>,
        amount -> Numeric,
    }
}

table! {
    ft_balances (ft_contract_id, owner) {
        ft_contract_id -> Text,
        owner -> Text,
        amount -> Numeric,
    }
}

table! {
    mb_store_minters (nft_contract_id, minter_id) {
        nft_contract_id -> Text,
        minter_id -> Text,
        receipt_id -> Nullable<Text>,
        timestamp -> Nullable<Timestamp>,
    }
}

table! {
    nft_activities (receipt_id, nft_contract_id, token_id, kind) {
        receipt_id -> Text,
        tx_sender -> Text,
        sender_pk -> Nullable<Text>,
        timestamp -> Timestamp,
        nft_contract_id -> Text,
        token_id -> Text,
        kind -> Text,
        action_sender -> Nullable<Text>,
        action_receiver -> Nullable<Text>,
        memo -> Nullable<Text>,
        price -> Nullable<Numeric>,
        currency -> Nullable<Text>,
    }
}

table! {
    nft_approvals (nft_contract_id, token_id, approved_account_id) {
        nft_contract_id -> Text,
        token_id -> Text,
        approved_account_id -> Text,
        approval_id -> Numeric,
        receipt_id -> Text,
        timestamp -> Timestamp,
    }
}

table! {
    nft_attributes (nft_metadata_id, nft_contract_id, attribute_type) {
        nft_metadata_id -> Text,
        nft_contract_id -> Text,
        attribute_type -> Text,
        attribute_value -> Nullable<Text>,
        attribute_display_type -> Nullable<Text>,
    }
}

table! {
    nft_contracts (id) {
        id -> Text,
        spec -> Text,
        name -> Text,
        symbol -> Nullable<Text>,
        icon -> Nullable<Text>,
        base_uri -> Nullable<Text>,
        reference -> Nullable<Text>,
        reference_hash -> Nullable<Text>,
        created_at -> Nullable<Timestamp>,
        created_receipt_id -> Nullable<Text>,
        owner_id -> Nullable<Text>,
        is_mintbase -> Bool,
        content_flag -> Nullable<Text>,
        category -> Nullable<Text>,
    }
}

table! {
    nft_earnings (nft_contract_id, token_id, market_id, approval_id, receiver_id, is_referral, is_mintbase_cut) {
        nft_contract_id -> Text,
        token_id -> Text,
        market_id -> Text,
        approval_id -> Numeric,
        offer_id -> Int8,
        receipt_id -> Text,
        timestamp -> Timestamp,
        receiver_id -> Text,
        currency -> Text,
        amount -> Numeric,
        is_referral -> Bool,
        is_mintbase_cut -> Bool,
        is_affiliate -> Nullable<Bool>,
    }
}

table! {
    nft_external_listings (nft_contract_id, token_id, market_id, approval_id) {
        nft_contract_id -> Text,
        token_id -> Text,
        market_id -> Text,
        approval_id -> Numeric,
        lister_id -> Text,
        listing_price -> Numeric,
        listed_at -> Timestamp,
        listing_receipt_id -> Text,
        currency -> Text,
        buyer_id -> Nullable<Text>,
        sale_price -> Nullable<Numeric>,
        sold_at -> Nullable<Timestamp>,
        sale_receipt_id -> Nullable<Text>,
        deleted_at -> Nullable<Timestamp>,
        deletion_receipt_id -> Nullable<Text>,
        failed_at -> Nullable<Timestamp>,
        failure_receipt_id -> Nullable<Text>,
    }
}

table! {
    nft_listings (nft_contract_id, token_id, market_id, approval_id) {
        nft_contract_id -> Text,
        token_id -> Text,
        market_id -> Text,
        approval_id -> Numeric,
        created_at -> Timestamp,
        receipt_id -> Text,
        kind -> Text,
        price -> Nullable<Numeric>,
        currency -> Text,
        listed_by -> Text,
        unlisted_at -> Nullable<Timestamp>,
        accepted_at -> Nullable<Timestamp>,
        accepted_offer_id -> Nullable<Int8>,
        metadata_id -> Nullable<Text>,
        invalidated_at -> Nullable<Timestamp>,
    }
}

table! {
    nft_metadata (id) {
        id -> Text,
        nft_contract_id -> Text,
        reference_blob -> Nullable<Jsonb>,
        title -> Nullable<Text>,
        description -> Nullable<Text>,
        media -> Nullable<Text>,
        media_hash -> Nullable<Text>,
        reference -> Nullable<Text>,
        reference_hash -> Nullable<Text>,
        extra -> Nullable<Text>,
        minter -> Nullable<Text>,
        base_uri -> Nullable<Text>,
        content_flag -> Nullable<Text>,
    }
}

table! {
    nft_offers (nft_contract_id, token_id, market_id, approval_id, offer_id) {
        nft_contract_id -> Text,
        token_id -> Text,
        market_id -> Text,
        approval_id -> Numeric,
        currency -> Text,
        offer_price -> Numeric,
        offered_by -> Text,
        offered_at -> Timestamp,
        receipt_id -> Text,
        offer_id -> Int8,
        referrer_id -> Nullable<Text>,
        referral_amount -> Nullable<Numeric>,
        withdrawn_at -> Nullable<Timestamp>,
        accepted_at -> Nullable<Timestamp>,
        expires_at -> Nullable<Timestamp>,
        invalidated_at -> Nullable<Timestamp>,
        outbid_at -> Nullable<Timestamp>,
        affiliate_id -> Nullable<Text>,
        affiliate_amount -> Nullable<Numeric>,
    }
}

table! {
    nft_tokens (nft_contract_id, token_id) {
        nft_contract_id -> Text,
        token_id -> Text,
        owner -> Text,
        mint_memo -> Nullable<Text>,
        last_transfer_timestamp -> Nullable<Timestamp>,
        last_transfer_receipt_id -> Nullable<Text>,
        minted_timestamp -> Nullable<Timestamp>,
        minted_receipt_id -> Nullable<Text>,
        burned_timestamp -> Nullable<Timestamp>,
        burned_receipt_id -> Nullable<Text>,
        minter -> Nullable<Text>,
        reference -> Nullable<Text>,
        reference_hash -> Nullable<Text>,
        copies -> Nullable<Int8>,
        issued_at -> Nullable<Timestamp>,
        expires_at -> Nullable<Timestamp>,
        starts_at -> Nullable<Timestamp>,
        updated_at -> Nullable<Timestamp>,
        metadata_id -> Nullable<Text>,
        royalties_percent -> Nullable<Int4>,
        royalties -> Nullable<Jsonb>,
        splits -> Nullable<Jsonb>,
    }
}

allow_tables_to_appear_in_same_query!(
    blocks,
    ft_activities,
    ft_balances,
    mb_store_minters,
    nft_activities,
    nft_approvals,
    nft_attributes,
    nft_contracts,
    nft_earnings,
    nft_external_listings,
    nft_listings,
    nft_metadata,
    nft_offers,
    nft_tokens,
);
