create index nft_unburned_meta_by_minter on nft_tokens(minter, burned_timestamp, minted_timestamp, metadata_id);