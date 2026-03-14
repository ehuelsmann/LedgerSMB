
create table open_item (
  id int generated always as identity primary key,
  item_number text not null unique,
  item_type char(2) not null check(item_type = ANY(ARRAY['gl', 'ar', 'ap']::text[])),
  account_id int not null references account(id)
  );

alter table acc_trans
  add column open_item_id int references open_item (id);

create index idx_acc_trans_open_item_id on acc_trans (open_item_id)
  where open_item_id is not null;

alter table account
  add column open_item_managed boolean not null default false;

alter table ar
  add column open_item_id int references open_item(id);

alter table ap
  add column open_item_id int references open_item(id);


--defer making AR/AP open item managed
--update account
--   set open_item_managed = true
-- where exists (select 1
--                 from account_link al
--                where al.description = ANY(ARRAY['AR', 'AP']::text[])
--                      and account.id = al.account_id)


comment on table open_item is
  $$Allows tracking of items to be cleared/handled in subsequent transactions. $$;

comment on column open_item.id is
  $$Internal identifier for the open item. $$;
comment on column open_item.item_number is
  $$Identifier as presented in the user interface. $$;
comment on column open_item.item_type is
  $$Type of open item; currently 'gl','ar' or 'ap'. $$;
comment on column acc_trans.open_item_id is
  $$The open item this journal line is linked to; this indicates an allocation (reduction) of the open item, unless the entry_id of this line item is the lowest entry_id in the set, in which case it is the opening balance. $$;
comment on column account.open_item_managed is
  $$Indicates whether postings on this account will be tracked using open items.$$;



create or replace function trigger_open_item_maintenance () returns trigger
as $$
begin
  return new;
end;
  $$ language plpgsql;


create trigger trigger_open_item_maintenance
  before insert or update on acc_trans
  for each row
    execute function trigger_open_item_maintenance();


insert into open_item (
  item_number, item_type, account_id
)
select invnumber, lower(al.description), chart_id
  from acc_trans
         join (select id, invnumber
                 from ar
                union
               select id, invnumber
                 from ap) aa
             on acc_trans.trans_id = aa.id
         join account_link al
             on acc_trans.chart_id = al.account_id
 where al.description in ('AR', 'AP')
 group by invnumber, lower(al.description), chart_id;


update ar
   set open_item_id = ac.open_item_id
       from acc_trans ac
 where ar.id = ac.trans_id
   and ac.open_item_id is not null;
update ap
   set open_item_id = ac.open_item_id
       from acc_trans ac
 where ap.id = ac.trans_id
   and ac.open_item_id is not null;


alter table ar
  alter column open_item_id set not null;

alter table ap
  alter column open_item_id set not null;

