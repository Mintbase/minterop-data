create index nft_activity_timestamp_index on nft_activities(timestamp);
create index nft_activity_contract_index on nft_activities(nft_contract_id);
create index nft_activity_sender_index on nft_activities(action_sender);