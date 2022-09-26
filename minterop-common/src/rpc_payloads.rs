use serde::Serialize;

#[derive(Serialize)]

pub struct Contract {
    pub contract_id: String,
}
#[derive(Serialize)]
pub struct Token {
    pub contract_id: String,
    pub token_ids: Vec<String>,
}
