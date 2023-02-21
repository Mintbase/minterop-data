create index nft_activity_timestamp_index on nft_activities(timestamp);
create index nft_activity_contract_index on nft_activities(timestamp, nft_contract_id);
create index nft_activity_sender_index on nft_activities(timestamp, action_sender);
create index nft_activity_kind_index on nft_activities(timestamp, kind);