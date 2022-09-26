#[macro_use]
extern crate diesel;
#[macro_use]
extern crate diesel_migrations;

pub mod db_rows;
pub mod rpc_payloads;
pub mod schema;

// re-exports
pub use bigdecimal;
pub use num_bigint;

pub fn pg_numeric<N>(x: N) -> bigdecimal::BigDecimal
where
    num_bigint::BigInt: From<N>,
{
    bigdecimal::BigDecimal::from(num_bigint::BigInt::from(x))
} 

// #[macro_export]
// macro_rules! run_embedded_migrations {
//     ($loc:expr, $pg:expr) => {
//         diesel_migrations::embed_migrations!($loc);

//         $crate::run_migrations($pg)
//     };
// }

diesel_migrations::embed_migrations!("./migrations");

pub fn run_migrations(pg_string: &str) -> anyhow::Result<()> {
    use diesel::Connection;

    let connection = diesel::PgConnection::establish(pg_string)?;

    embedded_migrations::run_with_output(&connection, &mut std::io::stdout())?;

    Ok(())
}
