

set client_min_messages = 'warning';


BEGIN;

CREATE OR REPLACE FUNCTION track_global_sequence() RETURNS trigger AS
$BODY$
  DECLARE
  t_new_reference text;
  t_old_reference text;
BEGIN
  if tg_relname in ('ar','ap') then
    t_new_reference := new.invnumber;
    t_old_reference := old.invnumber;
  else
    t_new_reference := new.reference;
    t_old_reference := old.reference;
  end if;
  IF tg_op = 'INSERT' THEN
    INSERT INTO transactions (id, table_name, transdate, approved, reference)
    VALUES (new.id, TG_RELNAME, new.transdate, new.approved, t_new_reference);
  ELSEIF tg_op = 'UPDATE' THEN
    IF new.id <> old.id
      OR new.approved <> old.approved
      OR new.transdate <> old.transdate
      OR t_new_reference <> t_old_reference THEN
        UPDATE transactions
           SET id = new.id,
               approved = new.approved,
               transdate = new.transdate,
               reference = t_new_reference
         WHERE id = old.id;
    END IF;
  ELSE
    DELETE FROM transactions WHERE id = old.id;
  END IF;
  RETURN new;
END;
$BODY$
  LANGUAGE plpgsql;

COMMENT ON FUNCTION track_global_sequence() IS
' This trigger is used to track the id sequence entries across the
transactions table, and with the ar, ap, and gl tables.  This is necessary
because these have not been properly refactored yet.
';


CREATE OR REPLACE FUNCTION gl_audit_trail_append()
RETURNS TRIGGER AS
$$
DECLARE
   t_reference text;
   t_row RECORD;
BEGIN

IF TG_OP = 'INSERT' then
   t_row := NEW;
ELSE
   t_row := OLD;
END IF;

IF TG_TABLE_NAME IN ('ar', 'ap') THEN
    t_reference := t_row.invnumber;
ELSE
    t_reference := t_row.reference;
END IF;

INSERT INTO audittrail (trans_id,tablename,reference, action, person_id)
values (t_row.id,TG_TABLE_NAME,t_reference, TG_OP, person__get_my_entity_id());

return null; -- AFTER TRIGGER ONLY, SAFE
END;
$$ language plpgsql security definer;


COMMENT ON FUNCTION gl_audit_trail_append() IS
$$ This provides centralized support for insertions into audittrail.
$$;


CREATE OR REPLACE FUNCTION prevent_closed_transactions() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE t_end_date date;
BEGIN
SELECT max(end_date) into t_end_date FROM account_checkpoint;
IF new.transdate <= t_end_date THEN
    RAISE EXCEPTION 'Transaction entered into closed period.  Transdate: %',
                   new.transdate;
END IF;
RETURN new;
END;
$$;

CREATE OR REPLACE FUNCTION trigger_parts_short() RETURNS TRIGGER
AS
'
BEGIN
  IF NEW.onhand >= NEW.rop THEN
    NOTIFY parts_short;
  END IF;
  RETURN NEW;
END;
' LANGUAGE PLPGSQL;


create or replace function cdc_update_last_updated()
  returns trigger as
$$
BEGIN
  IF TG_OP <> 'DELETE' THEN
    NEW.last_updated := NOW();
  END IF;
  RETURN NEW;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION trigger_workflow_user() RETURNS TRIGGER
AS $$
BEGIN
  IF TG_OP <> 'DELETE' THEN
    NEW.workflow_user = CURRENT_USER;
    NEW.workflow_entity_id = person__get_my_entity_id();
  END IF;
  RETURN NEW;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION trigger_ar_delete() RETURNS trigger AS $BODY$
BEGIN
  DELETE FROM aa WHERE id = NEW.id AND entity_class = 2;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trigger_ap_delete() RETURNS trigger AS $BODY$
BEGIN
  DELETE FROM aa WHERE id = NEW.id AND entity_class = 1;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trigger_ar_insert() RETURNS trigger AS $BODY$
BEGIN
  INSERT INTO aa (
      id,
      entity_credit_account,
      entity_class,
      amount_bc,
      amount_tc,
      netamount_bc,
      netamount_tc,
      curr,
      invnumber,
      quonumber,
      ordnumber,
      counterparty_reference,
      crdate,
      transdate,
      duedate,
      description,
      notes,
      intnotes,
      taxincluded,
      terms,
      person_id,
      shippingpoint,
      shipvia,
      language_code,
      invoice,
      reverse,
      is_return,
      approved,
      on_hold,
      force_closed
  )
  VALUES (
    NEW.id,
    NEW.entity_credit_account,
    2, -- as entity_class,
    NEW.amount_bc,
    NEW.amount_tc,
    NEW.netamount_bc,
    NEW.netamount_tc,
    NEW.curr,
    NEW.invnumber,
    NEW.quonumber,
    NEW.ordnumber,
    NEW.ponumber, -- as counterparty_reference,
    NEW.crdate,
    NEW.transdate,
    NEW.duedate,
    NEW.description,
    NEW.notes,
    NEW.intnotes,
    NEW.taxincluded,
    NEW.terms,
    NEW.person_id,
    NEW.shippingpoint,
    NEW.shipvia,
    NEW.language_code,
    NEW.invoice,
    NEW.reverse,
    NEW.is_return,
    NEW.approved,
    NEW.on_hold,
    NEW.force_closed
  );
END;
$BODY$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION trigger_ap_insert() RETURNS trigger AS $BODY$
BEGIN
  INSERT INTO aa (
      id,
      entity_credit_account,
      entity_class,
      amount_bc,
      amount_tc,
      netamount_bc,
      netamount_tc,
      curr,
      invnumber,
      quonumber,
      ordnumber,
      counterparty_reference,
      crdate,
      transdate,
      duedate,
      description,
      notes,
      intnotes,
      taxincluded,
      terms,
      person_id,
      shippingpoint,
      shipvia,
      language_code,
      invoice,
      reverse,
      is_return,
      approved,
      on_hold,
      force_closed
  )
  VALUES (
    NEW.id,
    NEW.entity_credit_account,
    1, -- as entity_class,
    NEW.amount_bc,
    NEW.amount_tc,
    NEW.netamount_bc,
    NEW.netamount_tc,
    NEW.curr,
    NEW.invnumber,
    NEW.quonumber,
    NEW.ordnumber,
    NEW.ponumber, -- as counterparty_reference,
    NEW.crdate,
    NEW.transdate,
    NEW.duedate,
    NEW.description,
    NEW.notes,
    NEW.intnotes,
    NEW.taxincluded,
    NEW.terms,
    NEW.person_id,
    NEW.shippingpoint,
    NEW.shipvia,
    NEW.language_code,
    NEW.invoice,
    NEW.reverse,
    NEW.is_return,
    NEW.approved,
    NEW.on_hold,
    NEW.force_closed
  );
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trigger_ar_update() RETURNS trigger AS $BODY$
BEGIN
  UPDATE aa
     SET id = NEW.id,
         entity_credit_account = NEW.entity_credit_account,
         amount_bc = NEW.amount_bc,
         amount_tc = NEW.amount_tc,
         netamount_bc = NEW.netamount_bc,
         netamount_tc = NEW.netamount_tc,
         curr = NEW.curr,
         invnumber = NEW.invnumber,
         quonumber = NEW.quonumber,
         ordnumber = NEW.ordnumber,
         counterparty_reference = NEW.ponumber,
         crdate = NEW.crdate,
         transdate = NEW.transdate,
         duedate = NEW.duedate,
         description = NEW.description,
         notes = NEW.notes,
         intnotes = NEW.intnotes,
         taxincluded = NEW.taxincluded,
         terms = NEW.terms,
         person_id = NEW.person_id,
         shippingpoint = NEW.shippingpoint,
         shipvia = NEW.shipvia,
         language_code = NEW.language_code,
         invoice = NEW.invoice,
         reverse = NEW.reverse,
         is_return = NEW.is_return,
         approved = NEW.approved,
         on_hold = NEW.on_hold,
         force_closed = NEW.force_closed
   WHERE id = OLD.id
     AND entity_class = 2;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trigger_ap_update() RETURNS trigger AS $BODY$
BEGIN
  UPDATE aa
     SET id = NEW.id,
         entity_credit_account = NEW.entity_credit_account,
         amount_bc = NEW.amount_bc,
         amount_tc = NEW.amount_tc,
         netamount_bc = NEW.netamount_bc,
         netamount_tc = NEW.netamount_tc,
         curr = NEW.curr,
         invnumber = NEW.invnumber,
         quonumber = NEW.quonumber,
         ordnumber = NEW.ordnumber,
         counterparty_reference = NEW.ponumber,
         crdate = NEW.crdate,
         transdate = NEW.transdate,
         duedate = NEW.duedate,
         description = NEW.description,
         notes = NEW.notes,
         intnotes = NEW.intnotes,
         taxincluded = NEW.taxincluded,
         terms = NEW.terms,
         person_id = NEW.person_id,
         shippingpoint = NEW.shippingpoint,
         shipvia = NEW.shipvia,
         language_code = NEW.language_code,
         invoice = NEW.invoice,
         reverse = NEW.reverse,
         is_return = NEW.is_return,
         approved = NEW.approved,
         on_hold = NEW.on_hold,
         force_closed = NEW.force_closed
   WHERE id = OLD.id
     AND entity_class = 1;
END;
$BODY$ LANGUAGE plpgsql;


update defaults set value = 'yes' where setting_key = 'module_load_ok';

COMMIT;
