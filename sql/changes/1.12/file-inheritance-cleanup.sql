
drop function if exists file_links_vrebuild();
drop function if exists file__list_links(int, int);

-- this file replaces the view "file_order_links" with the table "file_order_links"
drop view if exists file_links;
drop view if exists file_order_links;
drop view if exists file_tx_links;

alter table file_transaction no inherit file_base;
alter table file_order no inherit file_base;
alter table file_part no inherit file_base;
alter table file_entity no inherit file_base;
alter table file_eca no inherit file_base;
alter table file_internal no inherit file_base;
alter table file_incoming no inherit file_base;
alter table file_reconciliation no inherit file_base;

alter table file_base
  add column sha_hash bytea unique not null generated always as (sha512(content)) STORED;
alter table file_transaction
  add column sha_hash bytea unique not null generated always as (sha512(content)) STORED;
alter table file_order
  add column sha_hash bytea unique not null generated always as (sha512(content)) STORED;
alter table file_part
  add column sha_hash bytea unique not null generated always as (sha512(content)) STORED;
alter table file_entity
  add column sha_hash bytea unique not null generated always as (sha512(content)) STORED;
alter table file_eca
  add column sha_hash bytea unique not null generated always as (sha512(content)) STORED;
alter table file_internal
  add column sha_hash bytea unique not null generated always as (sha512(content)) STORED;
alter table file_incoming
  add column sha_hash bytea unique not null generated always as (sha512(content)) STORED;
alter table file_reconciliation
  add column sha_hash bytea unique not null generated always as (sha512(content)) STORED;

-- any files in file_base initially --> problems!

-- Copy all files into the central file storage, deduplicating (on conflict do nothing)
insert into file_base
select content, mime_type_id, file_name, description, uploaded_by,
       uploaded_at, id, ref_key, file_class from (
  select * from file_transaction
   union
  select * from file_order
   union
  select * from file_part
   union
  select * from file_entity
   union
  select * from file_eca
   union
  select * from file_internal
   union
  select * from file_incoming
) x
                on conflict (sha_hash) do nothing;


create table file_transaction_links (
  trans_id int references transactions(id),
  file_id int references file_base(id),
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  primary key (trans_id, file_id)
);

-- populate file_transaction_links and file_base from file_transaction...

insert into file_transaction_links (trans_id, file_id, file_name,
                                    description, uploaded_by, uploaded_at)
select ref_key, (select id from file_base fb where fb.sha_hash = ft.sha_hash),
       file_name, description, uploaded_by, uploaded_at
  from file_transaction ft;


create table file_order_links (
  oe_id int references oe(id),
  file_id int references file_base(id),
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  primary key (oe_id, file_id)
);

insert into file_order_links (oe_id, file_id, file_name,
                              description, uploaded_by, uploaded_at)
select ref_key, (select id from file_base fb where fb.sha_hash = fo.sha_hash),
       file_name, description, uploaded_by, uploaded_at
  from file_order fo;



create table file_parts_links (
  parts_id int references parts(id),
  file_id int references file_base(id),
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  primary key (parts_id, file_id)
);

insert into file_parts_links (parts_id, file_id, file_name,
                              description, uploaded_by, uploaded_at)
select ref_key, (select id from file_base fb where fb.sha_hash = fp.sha_hash),
       file_name, description, uploaded_by, uploaded_at
  from file_part fp;

drop table file_part;


create table file_entity_links (
  entity_id int references entity(id),
  file_id int references file_base(id),
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  primary key (entity_id, file_id)
);

insert into file_entity_links (entity_id, file_id, file_name,
                               description, uploaded_by, uploaded_at)
select ref_key, (select id from file_base fb where fb.sha_hash = fe.sha_hash),
       file_name, description, uploaded_by, uploaded_at
  from file_entity fe;

drop table file_entity;


create table file_eca_links (
  eca_id int references entity_credit_account(id),
  file_id int references file_base(id),
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  primary key (eca_id, file_id)
);

insert into file_eca_links (eca_id, file_id, file_name,
                            description, uploaded_by, uploaded_at)
select ref_key, (select id from file_base fb where fb.sha_hash = fe.sha_hash),
       file_name, description, uploaded_by, uploaded_at
  from file_eca fe;

drop table file_eca;


create table file_internal_links (
  file_id int references file_base(id),
  file_name text unique not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  primary key (file_id)
);

insert into file_internal_links (file_id, file_name,
                                 description, uploaded_by, uploaded_at)
select (select id from file_base fb where fb.sha_hash = fi.sha_hash),
       file_name, description, uploaded_by, uploaded_at
  from file_internal fi;

drop table file_internal;


create table file_incoming_links (
  file_id int references file_base(id),
  file_name text unique not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  primary key (file_id)
);

insert into file_incoming_links (file_id, file_name,
                                 description, uploaded_by, uploaded_at)
select (select id from file_base fb where fb.sha_hash = fi.sha_hash),
       file_name, description, uploaded_by, uploaded_at
  from file_incoming fi;

drop table file_incoming;


create table file_reconciliation_links (
  file_id int references file_base(id),
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  primary key (file_id)
);

insert into file_reconciliation_links (file_id, file_name,
                                       description, uploaded_by, uploaded_at)
select (select id from file_base fb where fb.sha_hash = fr.sha_hash),
       file_name, description, uploaded_by, uploaded_at
  from file_reconciliation fr;

drop table file_reconciliation;




drop table file_view_catalog;

drop rule file_sec_insert_tx_oe on file_secondary_attachment;
drop rule file_sec_insert_oe_oe on file_secondary_attachment;
drop rule file_sec_insert_oe_tx on file_secondary_attachment;


insert into file_transaction_links (trans_id, file_id, file_name,
                                    description, uploaded_by, uploaded_at)
select fotx.ref_key, (select id from file_base fb where fb.sha_hash = ft.sha_hash),
       ft.file_name, ft.description, fotx.attached_by, fotx.attached_at
  from file_transaction ft
         join file_order_to_tx fotx
             on ft.id = fotx.file_id;


insert into file_order_links (oe_id, file_id, file_name,
                              description, uploaded_by, uploaded_at)
select foto.ref_key, (select id from file_base fb where fb.sha_hash = fo.sha_hash),
       fo.file_name, fo.description, foto.attached_by, foto.attached_at
  from file_order fo
         join file_order_to_order foto
             on fo.id = foto.file_id;

insert into file_order_links (oe_id, file_id, file_name,
                              description, uploaded_by, uploaded_at)
select ftto.ref_key, (select id from file_base fb where fb.sha_hash = ft.sha_hash),
       ft.file_name, ft.description, ftto.attached_by, ftto.attached_at
  from file_transaction ft
         join file_tx_to_order ftto
             on ft.id = ftto.file_id;



drop table file_order_to_order;
drop table file_tx_to_order;
drop table file_order_to_tx;
drop table file_secondary_attachment;


drop table file_transaction;
drop table file_order;
