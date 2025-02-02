
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
in_description text, in_id int, in_ref_key int, in_file_class int)

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
  insert into file_incoming_links (file_id, file_name, description, uploaded_by)
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
(in_content bytea, in_mime_type_id int, in_file_name text,
in_description text)
RETURNS file_internal_links LANGUAGE SQL AS
  $$
  delete from file_internal_links where file_name = in_file_name;

  insert into file_internal_links (file_content_id, file_name, description, uploaded_by)
  values (file__store(in_content, in_mime_type_id), in_file_name, in_description,
          (select entity_id from users where username = SESSION_USER))
  returning *;
$$;

COMMENT ON FUNCTION file__save_internal
(in_content bytea, in_mime_type_id int, in_file_name text,
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
       mime_type text,
       file_name text,
       description text,
       uploaded_by_id int,
       uploaded_by_name text,
       uploaded_at timestamp,
       id int,
       ref_key int,
       file_class int,
       content bytea
);

CREATE OR REPLACE FUNCTION file__get_for_template
(in_ref_key int, in_file_class int)
RETURNS SETOF file_list_item AS
$$

SELECT m.mime_type, CASE WHEN f.file_class = 3 THEN ref_key ||'-'|| f.file_name
                         ELSE f.file_name END,
       f.description, f.uploaded_by, e.name,
       f.uploaded_at, f.id, f.ref_key, f.file_class,  f.content
  FROM mime_type m
  JOIN file_base f ON f.mime_type_id = m.id
  JOIN entity e ON f.uploaded_by = e.id
 WHERE f.ref_key = $1 and f.file_class = $2
       AND m.invoice_include
       OR f.id IN (SELECT max(fb.id)
                   FROM file_base fb
                   JOIN mime_type m ON fb.mime_type_id = m.id
                        AND m.mime_type ilike 'image%'
                   JOIN invoice i ON i.trans_id = $1
                        AND i.parts_id = fb.ref_key
                  WHERE fb.file_class = 3
               GROUP BY ref_key)
$$ language sql;


CREATE OR REPLACE FUNCTION file__list_by(in_ref_key int, in_file_class int)
RETURNS SETOF file_list_item AS
$$

SELECT m.mime_type, f.file_name, f.description, f.uploaded_by, e.name,
       f.uploaded_at, f.id, f.ref_key, f.file_class,
       case when m.mime_type = 'text/x-uri' THEN f.content ELSE NULL END
  FROM mime_type m
  JOIN file_base f ON f.mime_type_id = m.id
  JOIN entity e ON f.uploaded_by = e.id
 WHERE f.ref_key = $1 and f.file_class = $2;

$$ language sql;

COMMENT ON FUNCTION file__list_by(in_ref_key int, in_file_class int) IS
$$ Returns a list of files attached to a database object.  No content is
retrieved.$$;


CREATE OR REPLACE FUNCTION file__delete(in_id int, in_file_class int)
RETURNS void AS
$$
DELETE FROM file_base where id = in_id and file_class = in_file_class;
$$ language sql;

COMMENT ON FUNCTION file__delete(in_id int, in_file_class int) IS
$$ Deletes the file identified by in_id and in_file_class.$$;

CREATE OR REPLACE FUNCTION file__get(in_id int, in_file_class int)
RETURNS file_base AS
$$
SELECT * FROM file_base where id = $1 and file_class = $2;
$$ language sql;

COMMENT ON FUNCTION file__get(in_id int, in_file_class int) IS
$$ Retrieves the file information specified including content.$$;

CREATE OR REPLACE FUNCTION file__get_by_name(in_file_name text, in_ref_key int,
in_file_class int)
RETURNS file_base AS
$$
SELECT * FROM file_base where file_name = in_file_name
                              and ref_key = in_ref_key
                              and file_class = in_file_class;
$$ language sql;

COMMENT ON FUNCTION file__get_by_name(in_file_name text, in_ref_key int, in_file_class int) IS
$$ Retrieves the file information specified including content.$$;



update defaults set value = 'yes' where setting_key = 'module_load_ok';

COMMIT;
