-- -------------------- FT Core and Metadata standards --------------------- --

create table ft_balances (
    ft_contract_id text    not null    check(ft_contract_id <> ''),
    owner          text    not null    check(owner <> ''),
    amount         numeric not null,
    primary key(ft_contract_id, owner)
);

create table ft_activities (
  receipt_id      text      not null,
  timestamp       timestamp not null,
  ft_contract_id  text      not null,
  kind            text      not null,
  action_sender   text,
  action_receiver text,
  memo            text,
  amount          numeric,
  primary key(receipt_id, ft_contract_id, kind, action_sender, action_receiver)
);
