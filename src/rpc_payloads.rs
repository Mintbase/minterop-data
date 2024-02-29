use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
#[cfg_attr(test, derive(PartialEq))]
#[serde(tag = "kind", content = "payload")]
pub enum RpcMessage {
    #[serde(rename = "contract")]
    HandleContractPayload {
        contract_id: String,
        refresh: Option<bool>, // as update to keep it backwards compatible
    },
    #[serde(rename = "token")]
    HandleTokenPayload {
        contract_id: String,
        token_ids: Vec<String>,
        refresh: Option<bool>,
        minter: Option<String>,
    },
    #[serde(rename = "metadata")]
    HandleMetadataPayload {
        contract_id: String,
        metadata_id: u64,
        minters_allowlist: Option<Vec<String>>,
        price: String,
        royalties: Option<serde_json::Value>,
        max_supply: Option<u32>,
        last_possible_mint: Option<u64>,
        is_locked: bool,
        refresh: Option<bool>,
        creator: String,
    },
    #[serde(rename = "sale")]
    HandleSalePayload {
        contract_id: String,
        token_id: String,
        new_owner_id: String,
        receipt_id: String,
    },
}

impl RpcMessage {
    pub fn from_contract(contract_id: String, update: bool) -> Self {
        Self::HandleContractPayload {
            contract_id,
            refresh: Some(update),
        }
    }

    pub fn from_token(
        contract_id: String,
        token_ids: Vec<String>,
        minter: Option<String>,
    ) -> Self {
        Self::HandleTokenPayload {
            contract_id,
            token_ids,
            refresh: Some(false),
            minter,
        }
    }

    pub fn from_metadata(
        contract_id: String,
        metadata_id: u64,
        minters_allowlist: Option<Vec<String>>,
        price: u128,
        royalties: Option<serde_json::Value>,
        max_supply: Option<u32>,
        last_possible_mint: Option<u64>,
        is_locked: bool,
        creator: String,
    ) -> Self {
        Self::HandleMetadataPayload {
            contract_id,
            metadata_id,
            minters_allowlist,
            royalties,
            max_supply,
            last_possible_mint,
            is_locked,
            price: price.to_string(),
            refresh: Some(false),
            creator,
        }
    }

    pub fn from_sale(
        contract_id: String,
        token_id: String,
        new_owner_id: String,
        receipt_id: String,
    ) -> Self {
        Self::HandleSalePayload {
            contract_id,
            token_id,
            new_owner_id,
            receipt_id,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::rpc_payloads::RpcMessage::{
        HandleContractPayload, HandleTokenPayload,
    };
    const CONTRACT_PAYLOAD_STR: &str = r#"{"kind":"contract","payload":{"contract_id":"foo.near","refresh":null}}"#;
    const TOKEN_PAYLOAD_STR: &str = r#"{"kind":"token","payload":{"contract_id":"foo.near","token_ids":["bar"],"refresh":null,"minter":"foo.near"}}"#;

    fn token_payload() -> RpcMessage {
        HandleTokenPayload {
            contract_id: "foo.near".to_string(),
            token_ids: vec!["bar".to_string()],
            refresh: None,
            minter: Some("foo.near".to_string()),
        }
    }

    fn contract_payload() -> RpcMessage {
        HandleContractPayload {
            contract_id: "foo.near".to_string(),
            refresh: None,
        }
    }

    #[test]
    fn token_payload_serializes() {
        assert_eq!(
            serde_json::to_string(&token_payload()).unwrap(),
            TOKEN_PAYLOAD_STR.to_string()
        )
    }

    #[test]
    fn token_payload_deserializes() {
        assert_eq!(
            serde_json::from_str::<RpcMessage>(TOKEN_PAYLOAD_STR).unwrap(),
            token_payload()
        )
    }

    #[test]
    fn contract_payload_serializes() {
        assert_eq!(
            serde_json::to_string(&contract_payload()).unwrap(),
            CONTRACT_PAYLOAD_STR.to_string()
        )
    }

    #[test]
    fn contract_payload_deserializes() {
        assert_eq!(
            serde_json::from_str::<RpcMessage>(CONTRACT_PAYLOAD_STR).unwrap(),
            contract_payload()
        )
    }
}
