FROM lukemathwalker/cargo-chef:latest-rust-1.60 AS chef
WORKDIR /app

# Planning the actual build
FROM chef AS planner
COPY minterop-common/Cargo.toml      minterop-common/Cargo.toml
COPY Cargo.lock Cargo.toml ./
RUN cargo chef prepare --recipe-path recipe.json

# Building
FROM chef AS builder
WORKDIR /app
# Build dependencies so they are cached in an intermediary docker image
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
# Now build the actual app
COPY minterop-common/Cargo.toml      minterop-common/Cargo.toml
COPY minterop-common/migrations      minterop-common/migrations
COPY minterop-common/src             minterop-common/src
COPY Cargo.lock Cargo.toml ./
