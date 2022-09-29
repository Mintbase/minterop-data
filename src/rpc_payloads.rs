use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
#[cfg_attr(test, derive(PartialEq))]
#[serde(tag = "kind", content = "payload")]
pub enum RpcMessage {
    #[serde(rename = "contract")]
    HandleContractPayload { contract_id: String },
    #[serde(rename = "token")]
    HandleTokenPayload {
        contract_id: String,
        token_ids: Vec<String>,
    },
}

impl RpcMessage {
    pub fn from_contract(contract_id: String) -> Self {
        Self::HandleContractPayload { contract_id }
    }
    pub fn from_token(contract_id: String, token_ids: Vec<String>) -> Self {
        Self::HandleTokenPayload {
            contract_id,
            token_ids,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::rpc_payloads::RpcMessage::{HandleContractPayload, HandleTokenPayload};
    const CONTRACT_PAYLOAD_STR: &str =
        r#"{"kind":"contract","payload":{"contract_id":"foo.near"}}"#;
    const TOKEN_PAYLOAD_STR: &str = r#"{"kind":"token","payload":{"contract_id":"foo.near","token_ids":["bar"],"refresh":null,"minter":"foo.near"}}"#;

    fn token_payload() -> RpcMessage {
        HandleTokenPayload {
            contract_id: "foo.near".to_string(),
            token_ids: vec!["bar".to_string()],
        }
    }

    fn contract_payload() -> RpcMessage {
        HandleContractPayload {
            contract_id: "foo.near".to_string(),
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
