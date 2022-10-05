# Minterop Data

## Postgres and Hasura GraphQL/REST API configuration for Mintbase Indexers

Configurations here manage both **postgres database column migrations** and **hasura configuration** in a single script that can be run in one of three environments **sandbox (mainnet NEAR data)**, **testnet (testnet NEAR data)**, and **mainnet**.

Running `scripts/redeploy.sh [env]` can be done locally but will require a {environment_name}.env file will need to be present. Ask if you need help with the contents of this file.

**Note, local migrations should only ever be done run sandbox because they lack the inconsitency checks in CICD**

## Migrations

Migrations under the hood use [diesel](https://diesel.rs/), a Rust library for database manipulation. You will need to install this via cargo to test migrations locally.

<br>

## Hasura Config

At this time, environment variables for cloud triggers (ultimately this should be replaced) are required for each hasura configuration and this needs to be done manually.

## CICD / Redeploy

CICD will attempt to run migrations and apply hasura metadta. Whenever inconsistencies between these are detected, the run will fail.