
-- note that this upgrade silently discards 'till' and 'entity_id' from 'ar' and 'ap'.

create table aa (
  id integer NOT NULL DEFAULT nextval('id'),
  entity_credit_account integer NOT NULL,
  entity_class integer NOT NULL,
  amount_bc numeric,
  amount_tc numeric,
  netamount_bc numeric,
  netamount_tc numeric,
  curr character(3),
  invnumber text,
  quonumber text,
  ordnumber text,
  counterparty_reference text,
  crdate date,
  transdate date DEFAULT ('now'::text)::date,
  duedate date,
  description text,
  notes text,
  intnotes text,
  taxincluded boolean,
  terms smallint DEFAULT 0,
  person_id integer,
  shippingpoint text,
  shipvia text,
  language_code character varying(6),
  invoice boolean DEFAULT false,
  reverse boolean DEFAULT false,
  is_return boolean DEFAULT false,
  approved boolean NOT NULL DEFAULT true,
  on_hold boolean DEFAULT false,
  force_closed boolean,
  setting_sequence text,
  CONSTRAINT aa_pkey PRIMARY KEY (id),
  CONSTRAINT aa_curr_fkey FOREIGN KEY (curr) REFERENCES currency (curr),
  CONSTRAINT aa_eca_fkey FOREIGN KEY (entity_credit_account) REFERENCES entity_credit_account (id),
  CONSTRAINT aa_id_fkey FOREIGN KEY (id) REFERENCES transactions (id),
  CONSTRAINT aa_person_id_fkey FOREIGN KEY (person_id) REFERENCES entity_employee (entity_id),
  CONSTRAINT check_amount_curr CHECK (amount_bc IS NULL AND curr IS NULL OR amount_bc IS NOT NULL AND curr IS NOT NULL),
  CONSTRAINT check_invnumber CHECK (invnumber IS NOT NULL OR NOT approved),
  CONSTRAINT transdate_nullity CHECK (NOT approved OR transdate IS NOT NULL)
);

CREATE INDEX aa_entity_credit_account_idx ON aa (entity_credit_account);
CREATE UNIQUE INDEX aa_invnumber_unique_idx ON aa (invnumber) WHERE entity_class = 2 AND invnumber IS NOT NULL;


comment on table aa is $$
  This table holds both AR and AP positions.
  The distinguishing trait is that the entity_credit_account is a customer (entity_class = 2) or
  a vendor (entity_class = 1). For performance reasons, the entity class is replicated into this
  table, meaning that AR items have an entity_class = 2 and AP items have an entity_class = 1.$$;

comment on column aa.counterparty_reference is $$
  For AR transactions, this is the PO number.
  For AP transactions, this is the SO number.$$;

insert into aa
select
  id,
  entity_credit_account,
  2 as entity_class,
  amount_bc,
  amount_tc,
  netamount_bc,
  netamount_tc,
  curr,
  invnumber,
  quonumber,
  ordnumber,
  ponumber as counterparty_reference,
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
  force_closed,
  setting_sequence
  from ar;

insert into aa
select
  id,
  entity_credit_account,
  1 as entity_class,
  amount_bc,
  amount_tc,
  netamount_bc,
  netamount_tc,
  curr,
  invnumber,
  quonumber,
  ordnumber,
  ponumber as counterparty_reference,
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
  from ap;

drop view cash_impact;
drop table ar;
drop table ap;

create view ar as
  select
    id,
    entity_credit_account,
    amount_bc,
    amount_tc,
    netamount_bc,
    netamount_tc,
    curr,
    invnumber,
    quonumber,
    ordnumber,
    counterparty_reference as ponumber,
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
    force_closed,
    setting_sequence
    from aa
   where entity_class = 2;

create view ap as
  select
    id,
    entity_credit_account,
    amount_bc,
    amount_tc,
    netamount_bc,
    netamount_tc,
    curr,
    invnumber,
    quonumber,
    ordnumber,
    counterparty_reference as ponumber,
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
    force_closed,
    setting_sequence
    from aa
   where entity_class = 1;


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
         counterparty_reference = NEW.sonumber,
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
         counterparty_reference = NEW.sonumber,
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


CREATE TRIGGER ar_insert INSTEAD OF INSERT ON ar FOR EACH ROW EXECUTE FUNCTION trigger_ar_insert();
CREATE TRIGGER ap_insert INSTEAD OF INSERT ON ap FOR EACH ROW EXECUTE FUNCTION trigger_ap_insert();

CREATE TRIGGER ar_update INSTEAD OF UPDATE ON ar FOR EACH ROW EXECUTE FUNCTION trigger_ar_update();
CREATE TRIGGER ap_update INSTEAD OF UPDATE ON ap FOR EACH ROW EXECUTE FUNCTION trigger_ap_update();

CREATE TRIGGER ar_delete INSTEAD OF DELETE ON ar FOR EACH ROW EXECUTE FUNCTION trigger_ar_delete();
CREATE TRIGGER ap_delete INSTEAD OF DELETE ON ap FOR EACH ROW EXECUTE FUNCTION trigger_ap_delete();



-- RECREATE cash_impact

CREATE VIEW cash_impact AS
SELECT id, '1'::numeric
 AS portion, 'gl' as rel, gl.transdate FROM gl
UNION ALL
 SELECT id, CASE WHEN gl.amount_bc = 0 THEN 0 -- avoid div by 0
                 WHEN gl.transdate = ac.transdate
                      THEN 1 + sum(ac.amount_bc) / gl.amount_bc
                 ELSE
                      1 - (gl.amount_bc - sum(ac.amount_bc)) / gl.amount_bc
                END , 'ar' as rel, ac.transdate
  FROM ar gl
  JOIN acc_trans ac ON ac.trans_id = gl.id
  JOIN account_link al ON ac.chart_id = al.account_id and al.description = 'AR'
 GROUP BY gl.id, gl.amount_bc, ac.transdate, gl.transdate
UNION ALL
SELECT id, CASE WHEN gl.amount_bc = 0 THEN 0
                WHEN gl.transdate = ac.transdate
                     THEN 1 - sum(ac.amount_bc) / gl.amount_bc
                ELSE
                     1 - (gl.amount_bc + sum(ac.amount_bc)) / gl.amount_bc
            END, 'ap' as rel, ac.transdate
  FROM ap gl
  JOIN acc_trans ac ON ac.trans_id = gl.id
  JOIN account_link al ON ac.chart_id = al.account_id and al.description = 'AP'
 GROUP BY gl.id, gl.amount_bc, ac.transdate, gl.transdate;

COMMENT ON VIEW cash_impact IS
$$ This view is used by cash basis reports to determine the fraction of a
transaction to be counted.$$;
