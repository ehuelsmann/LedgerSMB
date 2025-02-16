
-- unused views and functions

drop function if exists file_get_by_name(text, int, int);
drop function if exists file__get_for_template(int, int);
drop function if exists file_links_vrebuild();
drop function if exists file__list_links(int, int);

drop view if exists file_links;
drop view if exists file_order_links;
drop view if exists file_tx_links;

drop table if exists file_view_catalog;

-- unravel 'file_base' inheritance

create table file_content (
  id int generated always as identity,
  sha512sum bytea generated always as (sha512(content)) stored,
  content bytea not null,
  mime_type_id int not null references mime_type (id),
  primary key (id)
  );

alter table file_eca no inherit file_base;
alter table file_email no inherit file_base;
alter table file_entity no inherit file_base;
alter table file_incoming no inherit file_base;
alter table file_internal no inherit file_base;
alter table file_part no inherit file_base;
alter table file_order no inherit file_base;
alter table file_reconciliation no inherit file_base;
alter table file_transaction no inherit file_base;

alter table file_eca
  add column content_id int references file_content (id),
  add column uri text,
  add check ((content_id is null) != (uri is null));
alter table file_entity
  add column content_id int references file_content (id),
  add column uri text,
  add check ((content_id is null) != (uri is null));
alter table file_email
  add column content_id int references file_content (id),
  add column uri text,
  add check ((content_id is null) != (uri is null));
alter table file_incoming
  add column content_id int not null references file_content (id);
alter table file_internal
  add column content_id int not null references file_content (id);
alter table file_order
  add column content_id int references file_content (id),
  add column uri text,
  add check ((content_id is null) != (uri is null));
alter table file_part
  add column content_id int references file_content (id),
  add column uri text,
  add check ((content_id is null) != (uri is null));
alter table file_reconciliation
  add column content_id int references file_content (id),
  add column uri text,
  add check ((content_id is null) != (uri is null));
alter table file_transaction
  add column content_id int references file_content (id),
  add column uri text,
  add check ((content_id is null) != (uri is null));

-- any files in file_base initially --> problems!

create function pg_temp.save_file_content(in_content bytea, in_mime_type_id int)
  returns int as $$
  declare
    content_id int;
  begin
    select id into content_id
      from file_content
     where sha512(in_content) = sha512sum
       and in_content = content;

    if content_id is not null then
      return content_id;
    end if;

    insert into file_content (content, mime_type_id)
        values (in_content, in_mime_type_id)
      returning id into content_id;

    return content_id;
  end;
$$ language plpgsql;

create function pg_temp.save_uri_content(in_content bytea, in_mime_type_id int)
  returns text as $$
  begin
    perform *
       from mime_type
      where mime_type = 'text/x-uri'
        and id = in_mime_type_id;

    if found then
      return content::text;
    else
      return null;
    end if;
  end;
  $$ language plpgsql;

-- Copy all files into the central file storage, deduplicating (on conflict do nothing)
update file_eca
   set content_id = pg_temp.save_file_content(content, mime_type_id),
       uri = pg_temp.save_uri_content(content, mime_type_id);

update file_email
   set content_id = pg_temp.save_file_content(content, mime_type_id),
       uri = pg_temp.save_uri_content(content, mime_type_id);

update file_entity
   set content_id = pg_temp.save_file_content(content, mime_type_id),
       uri = pg_temp.save_uri_content(content, mime_type_id);

update file_incoming
   set content_id = pg_temp.save_file_content(content, mime_type_id);

update file_internal
   set content_id = pg_temp.save_file_content(content, mime_type_id);

update file_order
   set content_id = pg_temp.save_file_content(content, mime_type_id),
       uri = pg_temp.save_uri_content(content, mime_type_id);

update file_part
   set content_id = pg_temp.save_file_content(content, mime_type_id),
       uri = pg_temp.save_uri_content(content, mime_type_id);

update file_transaction
   set content_id = pg_temp.save_file_content(content, mime_type_id),
       uri = pg_temp.save_uri_content(content, mime_type_id);


-- populate file_transaction_links and file_base from file_transaction...

create table file_eca_links (
  id int not null primary key generated always as identity,
  eca_id int references entity_credit_account(id),
  file_content_id int references file_content (id),
  uri text,
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  unique nulls not distinct (eca_id, file_content_id, uri),
  check ((file_content_id is null) != (uri is null))
);

insert into file_eca_links (
  eca_id, file_content_id, uri, file_name, description, uploaded_by, uploaded_at)
select ref_key, content_id, uri, file_name, description, uploaded_by, uploaded_at
  from file_eca;


create table file_email_links (
  id int not null primary key generated always as identity,
  email_workflow_id int references email(workflow_id),
  file_content_id int references file_content (id),
  uri text,
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  unique nulls not distinct (email_workflow_id, file_content_id, uri),
  check ((file_content_id is null) != (uri is null))
);

insert into file_email_links (
  email_workflow_id, file_content_id, uri, file_name, description, uploaded_by, uploaded_at)
select ref_key, content_id, uri, file_name, description, uploaded_by, uploaded_at
  from file_email;


create table file_entity_links (
  id int not null primary key generated always as identity,
  entity_id int references entity(id),
  file_content_id int references file_content (id),
  uri text,
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  unique nulls not distinct (entity_id, file_content_id, uri),
  check ((file_content_id is null) != (uri is null))
);

insert into file_entity_links (
  entity_id, file_content_id, uri, file_name, description, uploaded_by, uploaded_at)
select ref_key, content_id, uri, file_name, description, uploaded_by, uploaded_at
  from file_entity;


create table file_incoming_links (
  id int not null primary key generated always as identity,
  file_content_id int references file_content (id),
  uri text,
  file_name text unique not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  unique nulls not distinct (file_content_id, uri),
  check ((file_content_id is null) != (uri is null))
);

insert into file_incoming_links (
  file_content_id, file_name, description, uploaded_by, uploaded_at)
select content_id, file_name, description, uploaded_by, uploaded_at
  from file_incoming;


create table file_internal_links (
  id int not null primary key generated always as identity,
  file_content_id int references file_content (id),
  uri text,
  file_name text unique not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  unique nulls not distinct (file_content_id, uri),
  check ((file_content_id is null) != (uri is null))
);

insert into file_internal_links (
  file_content_id, file_name, description, uploaded_by, uploaded_at)
select content_id, file_name, description, uploaded_by, uploaded_at
  from file_internal;


create table file_oe_links (
  id int not null primary key generated always as identity,
  oe_id int references oe(id),
  file_content_id int references file_content (id),
  uri text,
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  unique nulls not distinct (oe_id, file_content_id, uri),
  check ((file_content_id is null) != (uri is null))
);

insert into file_oe_links (
  oe_id, file_content_id, uri, file_name, description, uploaded_by, uploaded_at)
select ref_key, content_id, uri, file_name, description, uploaded_by, uploaded_at
  from file_order;


create table file_parts_links (
  id int not null primary key generated always as identity,
  parts_id int references parts(id),
  file_content_id int references file_content (id),
  uri text,
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  unique nulls not distinct (parts_id, file_content_id, uri),
  check ((file_content_id is null) != (uri is null))
);

insert into file_parts_links (
  parts_id, file_content_id, uri, file_name, description, uploaded_by, uploaded_at)
select ref_key, content_id, uri, file_name, description, uploaded_by, uploaded_at
  from file_part;


create table file_reconciliation_links (
  id int not null primary key generated always as identity,
  cr_report_id int references cr_report(id),
  file_content_id int references file_content (id),
  uri text,
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  unique nulls not distinct (cr_report_id, file_content_id, uri),
  check ((file_content_id is null) != (uri is null))
);

insert into file_reconciliation_links (
  cr_report_id, file_content_id, uri, file_name, description, uploaded_by, uploaded_at)
select ref_key, content_id, uri, file_name, description, uploaded_by, uploaded_at
  from file_reconciliation;


create table file_transaction_links (
  id int not null primary key generated always as identity,
  trans_id int references transactions(id),
  file_content_id int references file_content (id),
  uri text,
  file_name text not null,
  description text,
  uploaded_by int not null references entity(id),
  uploaded_at timestamp not null default now(),
  unique nulls not distinct (trans_id, file_content_id, uri),
  check ((file_content_id is null) != (uri is null))
);

insert into file_transaction_links (
  trans_id, file_content_id, uri, file_name, description, uploaded_by, uploaded_at)
select ref_key, content_id, uri, file_name, description, uploaded_by, uploaded_at
  from file_transaction;



-- unravel 'file_secondary_attachment' inheritance
drop rule file_sec_insert_tx_oe on file_secondary_attachment;
drop rule file_sec_insert_oe_oe on file_secondary_attachment;
drop rule file_sec_insert_oe_tx on file_secondary_attachment;



insert into file_transaction_links (
  trans_id, file_content_id, file_name, description,
  uploaded_by, uploaded_at)
select fotx.ref_key, ft.content_id, ft.file_name, ft.description,
       fotx.attached_by, fotx.attached_at
  from file_order_to_tx fotx
         join file_transaction ft
             on ft.id = fotx.file_id;


insert into file_oe_links (
  oe_id, file_content_id, file_name, description,
  uploaded_by, uploaded_at)
select foto.ref_key, fo.content_id, fo.file_name, fo.description,
       foto.attached_by, foto.attached_at
  from file_order_to_order foto
         join file_order fo
             on fo.id = foto.file_id;

insert into file_oe_links (
  oe_id, file_content_id, file_name, description,
  uploaded_by, uploaded_at)
select ftto.ref_key, ft.content_id, ft.file_name, ft.description,
       ftto.attached_by, ftto.attached_at
  from file_tx_to_order ftto
         join file_transaction ft
             on ft.id = ftto.file_id;



drop table if exists file_order_to_order;
drop table if exists file_tx_to_order;
drop table if exists file_order_to_tx;
drop table if exists file_secondary_attachment;

drop table if exists file_eca;
drop table if exists file_email;
drop table if exists file_entity;
drop table if exists file_incoming;
drop table if exists file_internal;
drop table if exists file_part;
drop table if exists file_order;
drop table if exists file_reconciliation;
drop table if exists file_transaction;
drop table if exists file_base;
drop table if exists file_class cascade;
