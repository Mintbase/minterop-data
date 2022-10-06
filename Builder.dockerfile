FROM rustlang/rust:nightly-slim

WORKDIR /builder

RUN apt update
RUN apt-get install curl -y
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install libpq-dev nodejs yarn jq -y
RUN npm i -g hasura-cli prettier --y
RUN cargo install --debug taplo-cli
RUN cargo install --debug diesel_cli --no-default-features --features postgres

RUN curl -sS https://webi.sh/shfmt | sh