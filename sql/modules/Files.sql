
set client_min_messages = 'warning';


BEGIN;

DROP FUNCTION IF EXISTS file__get_mime_type(int, text);

CREATE OR REPLACE FUNCTION file__get_mime_type
 (in_mime_type_id int, in_mime_type_text text)
RETURNS mime_type AS
$$
DECLARE
   r mime_type;
BEGIN
  select * into r from mime_type
   where ($1 IS NULL OR id = $1) AND ($2 IS NULL OR mime_type = $2);

  if not found and in_mime_type_id is null and in_mime_type_text is not null then
    insert into mime_type (mime_type_text) values (in_mime_type_text)
    returning * into r;
  end if;

  return r;
END;
$$ language plpgsql;

COMMENT ON FUNCTION file__get_mime_type(in_mime_type_id int, in_mime_type text) IS
$$Retrieves mime type reference data or creates it.

Note that the reference data isn''t created when in_mime_type_id is
not null or that in_mime_type_text is null.
$$;

CREATE OR REPLACE FUNCTION file__store(in_content bytea,
                                       in_mime_type_id int)
  RETURNS int AS
  $$
  DECLARE
    content_id int;
  BEGIN
    if in_content is null then
      return null;
    end if;

    select id into content_id
      from file_content
     where sha512(in_content) = sha512sum
       and in_content = content;

    if found then
      return content_id;
    end if;

    insert into file_content (content, mime_type_id)
       values (in_content, in_mime_type_id)
              returning id into content_id;

    return content_id;
  END;
  $$ language plpgsql;

COMMENT ON FUNCTION file__store(bytea, int) IS
  $$ $$;

DROP FUNCTION IF EXISTS file__attach_to_tx
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_id int, in_ref_key int, in_file_class int);

CREATE OR REPLACE FUNCTION file__attach_to_tx
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_trans_id int)
RETURNS file_transaction_links
AS
$$
  delete from file_parts_links where file_name = in_file_name;

  insert into file_parts_links (file_content_id, file_name, description, uploaded_by)
  values (file__store(in_content, in_mime_type_id), in_file_name, in_description,
          (select entity_id from users where username = SESSION_USER))
  returning *;
$$ LANGUAGE SQL;

COMMENT ON FUNCTION file__attach_to_tx
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_trans_id int) IS
$$ Attaches or links a file to a transaction.  in_content OR id can be set.
Setting both raises an exception.$$;

DROP FUNCTION IF EXISTS file__attach_to_part
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_id int, in_ref_key int, in_file_class int);

CREATE OR REPLACE FUNCTION file__attach_to_part
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_parts_id int)
RETURNS file_parts_links
AS
$$
  delete from file_parts_links where file_name = in_file_name;

  insert into file_parts_links (file_content_id, file_name, description, uploaded_by)
  values (file__store(in_content, in_mime_type_id), in_file_name, in_description,
          (select entity_id from users where username = SESSION_USER))
  returning *;
$$ LANGUAGE SQL;

COMMENT ON FUNCTION file__attach_to_part
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_parts_id int) IS
$$ Attaches or links a file to a good or service.  in_content OR id can be set.
Setting both raises an exception.

Note that currently links (setting id) is NOT supported because we dont have a
use case of linking files to parts$$;

DROP FUNCTION IF EXISTS file__attach_to_email
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_id int, in_ref_key int, in_file_class int);

CREATE OR REPLACE FUNCTION file__attach_to_email
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_email_id int)
RETURNS file_email_links
AS
$$
  delete from file_email_links where file_name = in_file_name;

  insert into file_email_links (file_content_id, file_name, description, uploaded_by)
  values (file__store(in_content, in_mime_type_id), in_file_name, in_description,
          (select entity_id from users where username = SESSION_USER))
  returning *;
$$ LANGUAGE SQL;

COMMENT ON FUNCTION file__attach_to_email
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_email_id int) IS
$$ Attaches or links a file to an e-mail.  in_content OR id can be set.
Setting both raises an exception.

Note that currently links (setting id) is NOT supported because we dont have a
use case of linking files to e-mails$$;


DROP FUNCTION IF EXISTS file__attach_to_entity
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_id int, in_ref_key int, in_file_class int);

CREATE OR REPLACE FUNCTION file__attach_to_entity
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_entity_id int)
RETURNS file_entity_links
AS
$$
  delete from file_entity_links where file_name = in_file_name;

  insert into file_entity_links (file_content_id, file_name, description, uploaded_by)
  values (file__store(in_content, in_mime_type_id), in_file_name, in_description,
          (select entity_id from users where username = SESSION_USER))
  returning *;
$$ LANGUAGE SQL;

COMMENT ON FUNCTION file__attach_to_entity
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_entity_id int) IS
$$ Attaches or links a file to a contact or entity.  in_content OR id can be
set. Setting both raises an exception.

Note that currently links (setting id) is NOT supported because we dont have a
use case of linking files to entities$$;

DROP FUNCTION IF EXISTS file__attach_to_eca
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_id int, in_ref_key int, in_file_class int);

CREATE OR REPLACE FUNCTION file__attach_to_eca
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_eca_id int)
RETURNS file_eca_links
AS
$$
  delete from file_eca_links where file_name = in_file_name;

  insert into file_eca_links (file_content_id, file_name, description, uploaded_by)
  values (file__store(in_content, in_mime_type_id), in_file_name, in_description,
          (select entity_id from users where username = SESSION_USER))
  returning *;
$$ LANGUAGE SQL;

COMMENT ON FUNCTION file__attach_to_eca
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_eca_id int) IS
$$ Attaches or links a file to a good or service.  in_content OR id can be set.
Setting both raises an exception.

Note that currently links (setting id) is NOT supported because we dont have a
use case of linking files to entity credit accounts.$$;

DROP FUNCTION IF EXISTS file__attach_to_order
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_id int, in_ref_key int, in_file_class int);

CREATE OR REPLACE FUNCTION file__attach_to_order
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_oe_id int)
RETURNS file_oe_links
AS
$$
  delete from file_oe_links where file_name = in_file_name;

  insert into file_oe_links (file_content_id, file_name, description, uploaded_by)
  values (file__store(in_content, in_mime_type_id), in_file_name, in_description,
          (select entity_id from users where username = SESSION_USER))
  returning *;
$$ LANGUAGE SQL;

COMMENT ON FUNCTION file__attach_to_order
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_oe_id int) IS
$$ Attaches or links a file to an order.  in_content OR id can be set.
Setting both raises an exception.$$;

CREATE OR REPLACE FUNCTION file__save_incoming
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text)
RETURNS file_incoming_links LANGUAGE SQL AS
  $$
  insert into file_incoming_links (file_content_id, file_name, description, uploaded_by)
  values (file__store(in_content, in_mime_type_id), in_file_name, in_description,
          (select entity_id from users where username = SESSION_USER))
  returning *;
$$;

COMMENT ON FUNCTION file__save_incoming
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text) IS
$$If the file_name is not unique, a unique constraint violation will be thrown.
$$;

CREATE OR REPLACE FUNCTION file__save_internal
(in_content bytea, in_uri text, in_mime_type_id int, in_file_name text,
in_description text)
RETURNS file_internal_links LANGUAGE SQL AS
  $$
  insert into file_internal_links (file_content_id, uri, file_name, description, uploaded_by)
  values (file__store(in_content, in_mime_type_id), in_uri, in_file_name, in_description,
          (select entity_id from users where username = SESSION_USER))
         on conflict (file_name) do update
            set description = EXCLUDED.description,
                uri = EXCLUDED.uri,
                uploaded_by = EXCLUDED.uploaded_by,
                uploaded_at = NOW(),
                file_content_id = EXCLUDED.file_content_id
         returning *;
$$;

COMMENT ON FUNCTION file__save_internal
(in_content bytea, in_uri text, in_mime_type_id int, in_file_name text,
in_description text) IS
$$If the file_name is not unique, this overwrites the existing file.
$$;

DROP FUNCTION IF EXISTS file__attach_to_reconciliation
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_id int, in_ref_key int, in_file_class int);

CREATE OR REPLACE FUNCTION file__attach_to_reconciliation
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_cr_report_id int)
RETURNS file_reconciliation_links
AS
$$
  delete from file_reconciliation_links where file_name = in_file_name;

  insert into file_reconciliation_links (file_content_id, file_name, description, uploaded_by)
  values (file__store(in_content, in_mime_type_id), in_file_name, in_description,
          (select entity_id from users where username = SESSION_USER))
  returning *;
$$ LANGUAGE SQL;

COMMENT ON FUNCTION file__attach_to_reconciliation
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text, in_cr_report_id int) IS
$$ Attaches or links a file to an e-mail.  in_content OR id can be set.
Setting both raises an exception.

Note that currently links (setting id) is NOT supported because we dont have a
use case of linking files to e-mails$$;


DROP TYPE IF EXISTS file_list_item CASCADE;
CREATE TYPE file_list_item AS (
       file_name text,
       description text,
       uploaded_by_id int,
       uploaded_by_name text,
       uploaded_at timestamp,
       id int,
       uri text
);

CREATE OR REPLACE FUNCTION file_eca__list_by(in_eca_id int)
RETURNS SETOF file_list_item AS
$$
SELECT f.file_name, f.description, f.uploaded_by, e.name,
       f.uploaded_at, f.id, f.uri
  FROM file_eca_links f
  JOIN entity e ON f.uploaded_by = e.id
 WHERE f.eca_id = in_eca_id;
$$ language sql;

CREATE OR REPLACE FUNCTION file_email__list_by(in_email_id int)
RETURNS SETOF file_list_item AS
$$
SELECT f.file_name, f.description, f.uploaded_by, e.name,
       f.uploaded_at, f.id, f.uri
  FROM file_email_links f
  JOIN entity e ON f.uploaded_by = e.id
 WHERE f.email_workflow_id = in_email_id;
$$ language sql;

CREATE OR REPLACE FUNCTION file_entity__list_by(in_entity_id int)
RETURNS SETOF file_list_item AS
$$
SELECT f.file_name, f.description, f.uploaded_by, e.name,
       f.uploaded_at, f.id, f.uri
  FROM file_entity_links f
  JOIN entity e ON f.uploaded_by = e.id
 WHERE f.entity_id = in_entity_id;
$$ language sql;

CREATE OR REPLACE FUNCTION file_internal__list_by()
RETURNS SETOF file_list_item AS
$$
SELECT f.file_name, f.description, f.uploaded_by, e.name,
       f.uploaded_at, f.id, f.uri
  FROM file_internal_links f
  JOIN entity e ON f.uploaded_by = e.id;
$$ language sql;

COMMENT ON FUNCTION file_internal__list_by() IS
$$ Returns the list of files *not* attached to any database object; f.ex. logos$$;

CREATE OR REPLACE FUNCTION file_order__list_by(in_oe_id int)
RETURNS SETOF file_list_item AS
$$
SELECT f.file_name, f.description, f.uploaded_by, e.name,
       f.uploaded_at, f.id, f.uri
  FROM file_oe_links f
  JOIN entity e ON f.uploaded_by = e.id
 WHERE f.oe_id = in_oe_id;
$$ language sql;

CREATE OR REPLACE FUNCTION file_parts__list_by(in_parts_id int)
RETURNS SETOF file_list_item AS
$$
SELECT f.file_name, f.description, f.uploaded_by, e.name,
       f.uploaded_at, f.id, f.uri
  FROM file_parts_links f
  JOIN entity e ON f.uploaded_by = e.id
 WHERE f.parts_id = in_parts_id;
$$ language sql;

CREATE OR REPLACE FUNCTION file_reconciliation__list_by(in_report_id int)
RETURNS SETOF file_list_item AS
$$
SELECT f.file_name, f.description, f.uploaded_by, e.name,
       f.uploaded_at, f.id, f.uri
  FROM file_reconciliation_links f
  JOIN entity e ON f.uploaded_by = e.id
 WHERE f.cr_report_id = in_report_id;
$$ language sql;

CREATE OR REPLACE FUNCTION file_transaction__list_by(in_trans_id int)
RETURNS SETOF file_list_item AS
$$
SELECT f.file_name, f.description, f.uploaded_by, e.name,
       f.uploaded_at, f.id, f.uri
  FROM file_transaction_links f
  JOIN entity e ON f.uploaded_by = e.id
 WHERE f.trans_id = in_trans_id;
$$ language sql;


DROP TYPE IF EXISTS file__content CASCADE;
CREATE TYPE file__content AS (
  id int,
  content_id int,
  uri text,
  file_name text,
  description text,
  uploaded_by int,
  uploaded_at timestamp,
  sha512sum bytea,
  content bytea,
  mime_type_id int
  );


CREATE OR REPLACE FUNCTION file_eca__get(in_id int)
RETURNS SETOF file__content AS
$$
  SELECT l.id, file_content_id, uri, file_name,
         description, uploaded_by, uploaded_at,
         sha512sum, content, mime_type_id
    FROM file_eca_links l
    JOIN file_content fc ON l.file_content_id = fc.id
  where l.id = $1;
$$ language sql;

CREATE OR REPLACE FUNCTION file_email__get(in_id int)
RETURNS SETOF file__content AS
$$
  SELECT l.id, file_content_id, uri, file_name,
         description, uploaded_by, uploaded_at,
         sha512sum, content, mime_type_id
    FROM file_email_links l
    JOIN file_content fc ON l.file_content_id = fc.id
  where l.id = $1;
$$ language sql;

CREATE OR REPLACE FUNCTION file_entity__get(in_id int)
RETURNS SETOF file__content AS
$$
  SELECT l.id, file_content_id, uri, file_name,
         description, uploaded_by, uploaded_at,
         sha512sum, content, mime_type_id
    FROM file_entity_links l
    JOIN file_content fc ON l.file_content_id = fc.id
  where l.id = $1;
$$ language sql;

CREATE OR REPLACE FUNCTION file_incoming__get(in_id int)
RETURNS SETOF file__content AS
$$
  SELECT l.id, file_content_id, uri, file_name,
         description, uploaded_by, uploaded_at,
         sha512sum, content, mime_type_id
    FROM file_incoming_links l
    JOIN file_content fc ON l.file_content_id = fc.id
  where l.id = $1;
$$ language sql;

CREATE OR REPLACE FUNCTION file_internal__get(in_id int)
RETURNS SETOF file__content AS
$$
  SELECT l.id, file_content_id, uri, file_name,
         description, uploaded_by, uploaded_at,
         sha512sum, content, mime_type_id
    FROM file_internal_links l
    JOIN file_content fc ON l.file_content_id = fc.id
  where l.id = $1;
$$ language sql;

CREATE OR REPLACE FUNCTION file_order__get(in_id int)
RETURNS SETOF file__content AS
$$
  SELECT l.id, file_content_id, uri, file_name,
         description, uploaded_by, uploaded_at,
         sha512sum, content, mime_type_id
    FROM file_oe_links l
    JOIN file_content fc ON l.file_content_id = fc.id
  where l.id = $1;
$$ language sql;

CREATE OR REPLACE FUNCTION file_parts__get(in_id int)
RETURNS SETOF file__content AS
$$
  SELECT l.id, file_content_id, uri, file_name,
         description, uploaded_by, uploaded_at,
         sha512sum, content, mime_type_id
    FROM file_parts_links l
    JOIN file_content fc ON l.file_content_id = fc.id
  where l.id = $1;
$$ language sql;

CREATE OR REPLACE FUNCTION file_reconciliation__get(in_id int)
RETURNS SETOF file__content AS
$$
  SELECT l.id, file_content_id, uri, file_name,
         description, uploaded_by, uploaded_at,
         sha512sum, content, mime_type_id
    FROM file_reconciliation_links l
    JOIN file_content fc ON l.file_content_id = fc.id
  where l.id = $1;
$$ language sql;

CREATE OR REPLACE FUNCTION file_transaction__get(in_id int)
RETURNS SETOF file__content AS
$$
  SELECT l.id, file_content_id, uri, file_name,
         description, uploaded_by, uploaded_at,
         sha512sum, content, mime_type_id
    FROM file_transaction_links l
    JOIN file_content fc ON l.file_content_id = fc.id
  where l.id = $1;
$$ language sql;

CREATE OR REPLACE FUNCTION file_internal__get_by_name(in_file_name text)
RETURNS SETOF file__content AS
$$
  SELECT fi.id, file_content_id, uri, file_name, description, uploaded_by,
         uploaded_at, sha512sum, content, mime_type_id
    FROM file_internal_links fi
         JOIN file_content fc
           ON fi.file_content_id = fc.id
   WHERE file_name = in_file_name;
$$ language sql;

COMMENT ON FUNCTION file_internal__get_by_name(in_file_name text) IS
$$ Retrieves the file information specified including content.$$;



update defaults set value = 'yes' where setting_key = 'module_load_ok';

COMMIT;
