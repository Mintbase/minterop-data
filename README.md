# Minterop Data

## Postgres and Hasura GraphQL/REST API configuration for Mintbase Indexers

Configurations here manage both **postgres database column migrations** and **hasura configuration** in a single script that can be run in one of three environments **sandbox (mainnet NEAR data)**, **testnet (testnet NEAR data)**, and **mainnet**.

Running `scripts/redeploy.sh [env]` can be done locally but will require a {environment_name}.env file will need to be present. Ask if you need help with the contents of this file.

**Note, local migrations should only ever be done run sandbox because they lack the inconsitency checks in CICD**

## Migrations

Migrations under the hood use [diesel](https://diesel.rs/), a Rust library for database manipulation. You will need to install this via cargo to test migrations locally.

<br>

## Hasura Config

At this time, environment variables for cloud triggers (ultimately this should be replaced) are required for each hasura configuration and this [needs to be done manually](https://hasura.io/docs/latest/projects/env-vars/#introduction).

Currently `HASURA_POSTGRES`, `CLOUD_FUNCTIONS_BASE_URL`, and `NEAR_NETWORK` must be set for metadata to apply correctly.

## CICD

CICD uses a docker images with tools pre-installed (Builder.dockerfile) and deployed to ghcr.io. For more information on working with ghcr.io (Github Container Repo) see [docs here](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry)

CICD will attempt to run migrations and apply hasura metadta via scripts/redploy.sh.

Whenever inconsistencies between these are detected, the run will fail.


