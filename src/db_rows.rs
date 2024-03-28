use bigdecimal::BigDecimal;
use chrono::NaiveDateTime;

// ----------------------- core/interop functionality ----------------------- //
use crate::schema::*;
#[derive(Clone, Default, diesel::Insertable, diesel::Queryable)]
pub struct NftToken {
    pub token_id: String,
    pub nft_contract_id: String,
    pub owner: String,
    pub mint_memo: Option<String>,
    pub last_transfer_timestamp: Option<NaiveDateTime>,
    pub last_transfer_receipt_id: Option<String>,
    pub minted_timestamp: Option<NaiveDateTime>,
    pub minted_receipt_id: Option<String>,
    pub burned_timestamp: Option<NaiveDateTime>,
    pub burned_receipt_id: Option<String>,
    pub minter: Option<String>,
    pub reference: Option<String>,
    pub reference_hash: Option<String>,
    pub copies: Option<i64>,
    pub issued_at: Option<NaiveDateTime>,
    pub expires_at: Option<NaiveDateTime>,
    pub starts_at: Option<NaiveDateTime>,
    pub updated_at: Option<NaiveDateTime>,
    pub metadata_id: Option<String>,
    pub royalties_percent: Option<i32>,
    pub royalties: Option<serde_json::Value>,
    pub splits: Option<serde_json::Value>,
}

#[derive(
    Default, Clone, diesel::Insertable, diesel::Queryable, diesel::AsChangeset,
)]
#[table_name = "nft_metadata"]
pub struct NftMetadata {
    pub id: String,
    pub nft_contract_id: String,
    pub reference_blob: Option<serde_json::Value>,
    pub title: Option<String>,
    pub description: Option<String>,
    pub media: Option<String>,
    pub media_hash: Option<String>,
    pub reference: Option<String>,
    pub reference_hash: Option<String>,
    // pub media_size: Option<i64>,
    // pub animation_url: Option<String>,
    // pub animation_hash: Option<String>,
    // pub animation_size: Option<i64>,
    // pub youtube_url: Option<String>,
    // pub document_url: Option<String>,
    // pub document_hash: Option<String>,
    // pub external_url: Option<String>,
    // pub category: Option<String>,
    // #[diesel(column_name = "type")]
    // pub type_: Option<String>,
    // pub visibility: Option<String>,
    // pub media_type: Option<String>,
    // pub animation_type: Option<String>,
    // pub tags: Option<serde_json::Value>,
    pub extra: Option<String>,
    pub minter: Option<String>,
    pub base_uri: Option<String>,
    pub mb_internal_id: Option<BigDecimal>,
    pub price: Option<BigDecimal>,
    pub minters_allowlist: Option<Vec<String>>,
    pub royalties: Option<serde_json::Value>,
    pub royalty_percent: Option<BigDecimal>,
    pub max_supply: Option<BigDecimal>,
    pub last_possible_mint: Option<NaiveDateTime>,
    pub is_locked: Option<bool>,
    pub is_active: bool,
    pub ft_contract_id: Option<String>,
}

#[derive(Clone, diesel::Insertable, diesel::Queryable, diesel::AsChangeset)]
pub struct NftAttribute {
    pub nft_metadata_id: String,
    pub nft_contract_id: String,
    pub attribute_type: String,
    pub attribute_value: Option<String>,
    pub attribute_display_type: Option<String>,
}

#[derive(diesel::Insertable, diesel::Queryable, diesel::AsChangeset, Clone)]
pub struct NftContract {
    pub id: String,
    pub spec: String,
    pub name: String,
    pub symbol: String,
    pub icon: Option<String>,
    pub base_uri: Option<String>,
    pub reference: Option<String>,
    pub reference_hash: Option<String>,
    pub created_at: Option<NaiveDateTime>,
    pub created_receipt_id: Option<String>,
    pub owner_id: Option<String>,
    pub is_mintbase: bool,
    // content_flag omitted as it is purely manually curated
    pub category: Option<String>,
}

// --------------------- specifics for mintbase stores ---------------------- //
#[derive(diesel::Insertable, diesel::Queryable)]
pub struct NftApproval {
    pub nft_contract_id: String,
    pub token_id: String,
    pub approved_account_id: String,
    pub approval_id: BigDecimal,
    pub receipt_id: String,
    pub timestamp: NaiveDateTime,
}

#[derive(diesel::Insertable, diesel::Queryable)]
pub struct MbStoreMinter {
    pub nft_contract_id: String,
    pub minter_id: String,
    pub receipt_id: String,
    pub timestamp: NaiveDateTime,
}

// ------------------------- activities/provenance -------------------------- //
#[derive(diesel::Insertable, diesel::Queryable)]
#[table_name = "nft_activities"]
pub struct NftActivity {
    pub receipt_id: String,
    pub tx_sender: String,
    pub sender_pk: Option<String>,
    pub timestamp: NaiveDateTime,
    pub nft_contract_id: String,
    pub token_id: String,
    pub kind: String,
    /// transfers, approvals, revokes
    pub action_sender: String,
    pub action_receiver: Option<String>,
    pub memo: Option<String>,
    /// only on listing events
    pub price: Option<BigDecimal>,
    pub currency: Option<String>,
}

// TODO: replace with enum?
pub const NFT_ACTIVITY_KIND_MINT: &str = "mint";
pub const NFT_ACTIVITY_KIND_TRANSFER: &str = "transfer";
pub const NFT_ACTIVITY_KIND_BURN: &str = "burn";
pub const NFT_ACTIVITY_KIND_APPROVE: &str = "approve";
pub const NFT_ACTIVITY_KIND_REVOKE: &str = "revoke";
pub const NFT_ACTIVITY_KIND_REVOKE_ALL: &str = "revoke_all";
pub const NFT_ACTIVITY_KIND_LIST: &str = "list";
pub const NFT_ACTIVITY_KIND_UNLIST: &str = "unlist";
pub const NFT_ACTIVITY_KIND_SOLD: &str = "sale";
pub const NFT_ACTIVITY_KIND_MAKE_OFFER: &str = "make_offer";
pub const NFT_ACTIVITY_KIND_WITHDRAW_OFFER: &str = "withdraw_offer";

// --------------------------------- market --------------------------------- //
#[derive(diesel::Insertable, diesel::Queryable)]
pub struct NftListing {
    pub nft_contract_id: String,
    pub token_id: String,
    pub market_id: String,
    pub approval_id: BigDecimal,
    pub created_at: NaiveDateTime,
    pub receipt_id: String,
    pub kind: String,
    pub price: Option<BigDecimal>,
    pub currency: String,
    pub listed_by: String,
    pub unlisted_at: Option<NaiveDateTime>,
    pub accepted_at: Option<NaiveDateTime>,
    pub accepted_offer_id: Option<i64>,
    pub metadata_id: Option<String>,
    pub invalidated_at: Option<NaiveDateTime>,
}

pub const NFT_LISTING_KIND_SIMPLE: &str = "simple";
pub const NFT_LISTING_KIND_AUCTION: &str = "auction";

#[derive(diesel::Insertable, diesel::Queryable)]
pub struct NftOffer {
    pub nft_contract_id: String,
    pub token_id: String,
    pub market_id: String,
    pub approval_id: BigDecimal,
    pub currency: String,
    pub offer_price: BigDecimal,
    pub offered_by: String,
    pub offered_at: NaiveDateTime,
    pub receipt_id: String,
    pub offer_id: i64,
    pub referrer_id: Option<String>,
    pub affiliate_id: Option<String>,
    pub referral_amount: Option<BigDecimal>,
    pub affiliate_amount: Option<BigDecimal>,
    pub withdrawn_at: Option<NaiveDateTime>,
    pub accepted_at: Option<NaiveDateTime>,
    pub invalidated_at: Option<NaiveDateTime>,
    pub outbid_at: Option<NaiveDateTime>,
    pub expires_at: Option<NaiveDateTime>,
}

#[derive(diesel::Insertable, diesel::Queryable)]
pub struct NftEarning {
    pub nft_contract_id: String,
    pub token_id: String,
    pub market_id: String,
    pub approval_id: BigDecimal,
    pub offer_id: i64,
    pub receipt_id: String,
    pub timestamp: NaiveDateTime,
    pub currency: String,
    pub receiver_id: String,
    pub amount: BigDecimal,
    pub is_referral: bool,
    pub is_affiliate: bool,
    pub is_mintbase_cut: bool,
}

#[derive(diesel::Insertable, diesel::Queryable)]
pub struct NftExternalListing {
    pub nft_contract_id: String,
    pub token_id: String,
    pub market_id: String,
    pub approval_id: BigDecimal,
    pub lister_id: String,
    pub listing_price: BigDecimal,
    pub listed_at: NaiveDateTime,
    pub listing_receipt_id: String,
    pub currency: String,
    pub buyer_id: Option<String>,
    pub sale_price: Option<BigDecimal>,
    pub sold_at: Option<NaiveDateTime>,
    pub sale_receipt_id: Option<String>,
    pub deleted_at: Option<NaiveDateTime>,
    pub deletion_receipt_id: Option<String>,
    pub failed_at: Option<NaiveDateTime>,
    pub failure_receipt_id: Option<String>,
}

#[derive(diesel::Insertable, diesel::Queryable)]
pub struct AccessKey {
    pub account_id: String,
    pub public_key: String,
    pub created_at: NaiveDateTime,
    pub created_receipt_id: String,
    pub removed_at: Option<NaiveDateTime>,
    pub removed_receipt_id: Option<String>,
}

#[derive(diesel::Insertable, diesel::Queryable, diesel::AsChangeset, Clone)]
pub struct Account {
    pub account_id: String,
    pub created_at: NaiveDateTime,
    pub created_receipt_id: String,
    pub removed_at: Option<NaiveDateTime>,
    pub removed_receipt_id: Option<String>,
    pub beneficiary_id: Option<String>,
}
