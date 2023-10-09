-- Remove all keys that are not full access and remove column
delete from access_keys where permissions is not null;
alter table access_keys drop column permissions;
-- -- change primary key, remove columns
-- -- TODO: need to remove "duplicates"
-- alter table access_keys drop constraint access_keys_pkey drop index;
-- alter table access_keys
--   add constraint access_keys_pkey primary key (account_id, public_key);
-- alter table access_keys drop column created_at;
-- alter table access_keys drop column removed_at;
