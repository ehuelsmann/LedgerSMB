
set client_min_messages = 'warning';


BEGIN;

CREATE OR REPLACE FUNCTION parts__search_lite
(in_partnumber text, in_description text)
RETURNS SETOF parts AS
$$
SELECT *
  FROM parts
 WHERE ($1 IS NULL OR (partnumber ilike '%' || $1 || '%'))
       AND ($2 IS NULL
            OR description ilike '%' || $2 || '%'
            OR plainto_tsquery(get_default_lang()::regconfig, $2)
               =
               plainto_tsquery(get_default_lang()::regconfig, '')
            OR (description
                @@
                plainto_tsquery(get_default_lang()::regconfig, $2)))
       AND not obsolete
ORDER BY partnumber;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION parts__get_by_id(in_id int) RETURNS parts AS
$$
SELECT * FROM parts WHERE id = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION parts__get_by_partnumber(in_partnumber text)
RETURNS parts LANGUAGE SQL AS $$
SELECT * FROM parts WHERE partnumber = $1 and obsolete is NOT TRUE;
$$;


create or replace function parts__save_good(
  in_id int,
  in_partnumber text,
  in_description text,
  in_notes text,
  in_expense_accno_id int,
  in_income_accno_id int,
  in_inventory_accno_id int,
  in_listprice numeric,
  in_sellprice numeric,
  in_unit text,
  in_weight numeric,
  in_bin text,
  in_rop numeric,
  in_obsolete boolean,
  in_partsgroup_id int
) returns parts language plpgsql as $$
DECLARE
  rv parts;
BEGIN
  IF in_id is null THEN
    INSERT INTO parts (partnumber, description, notes,
                       expense_accno_id, income_accno_id, inventory_accno_id,
                       listprice, sellprice, unit, weight, bin, rop,
                       obsolete, partsgroup_id)
        VALUES (in_partnumber, in_description, in_notes,
                in_expense_accno_id, in_income_accno_id, in_inventory_accno_id,
                in_listprice, in_sellprice, in_unit, in_weight, in_bin, in_rop,
                in_obsolete, in_partsgroup_id)
    RETURNING * INTO rv;

    RETURN rv;
  END IF;

  UPDATE parts
     SET partnumber = in_partnumber,
         description =  in_description,
         notes = in_notes,
         expense_accno_id = expense_accno_id,
         income_accno_id = in_income_accno_id,
         inventory_accno_id = in_inventory_accno_id,
         listprice = in_listprice,
         sellprice = in_sellprice,
         unit = in_unit,
         weight = in_weight,
         bin = in_bin,
         rop = in_rop,
         obsolete = in_obsolete,
         partsgroup_id = in_partsgroup_id
  WHERE id = in_id
  RETURNING * INTO rv;

  RETURN rv;
END;
$$;



create or replace function parts__save_service(
  in_id int,
  in_partnumber text,
  in_description text,
  in_notes text,
  in_expense_accno_id int,
  in_income_accno_id int,
  in_listprice numeric,
  in_sellprice numeric,
  in_unit text,
  in_obsolete boolean,
  in_partsgroup_id int
) returns parts language plpgsql as $$
DECLARE
  rv parts;
BEGIN
  IF in_id is null THEN
    INSERT INTO parts (partnumber, description, notes,
                       expense_accno_id, income_accno_id, listprice,
                       sellprice, unit, obsolete, partsgroup_id)
        VALUES (in_partnumber, in_description, in_notes,
                in_expense_accno_id, in_income_accno_id, in_listprice,
                in_sellprice, in_unit, in_obsolete, in_partsgroup_id)
    RETURNING * INTO rv;

    RETURN rv;
  END IF;

  UPDATE parts
     SET partnumber = in_partnumber,
         description =  in_description,
         notes = in_notes,
         expense_accno_id = expense_accno_id,
         income_accno_id = in_income_accno_id,
         listprice = in_listprice,
         sellprice = in_sellprice,
         unit = in_unit,
         obsolete = in_obsolete,
         partsgroup_id = in_partsgroup_id
  WHERE id = in_id
  RETURNING * INTO rv;

  RETURN rv;
END;
$$;


create or replace function parts__save_overhead(
  in_id int,
  in_partnumber text,
  in_description text,
  in_notes text,
  in_expense_accno_id int,
  in_inventory_accno_id int,
  in_listprice numeric,
  in_sellprice numeric,
  in_unit text,
  in_obsolete boolean,
  in_partsgroup_id int
) returns parts language plpgsql as $$
DECLARE
  rv parts;
BEGIN
  IF in_id is null THEN
    INSERT INTO parts (partnumber, description, notes,
                       expense_accno_id, inventory_accno_id, listprice,
                       sellprice, unit, obsolete, partsgroup_id)
        VALUES (in_partnumber, in_description, in_notes,
                in_expense_accno_id, in_inventory_accno_id, in_listprice,
                in_sellprice, in_unit, in_obsolete, in_partsgroup_id)
    RETURNING * INTO rv;

    RETURN rv;
  END IF;

  UPDATE parts
     SET partnumber = in_partnumber,
         description =  in_description,
         notes = in_notes,
         expense_accno_id = expense_accno_id,
         inventory_accno_id = in_inventory_accno_id,
         listprice = in_listprice,
         sellprice = in_sellprice,
         unit = in_unit,
         obsolete = in_obsolete,
         partsgroup_id = in_partsgroup_id
  WHERE id = in_id
  RETURNING * INTO rv;

  RETURN rv;
END;
$$;

CREATE OR REPLACE FUNCTION parts__delete(in_id int)
RETURNS parts LANGUAGE sql AS
$$
  DELETE FROM parts WHERE id = in_id
  RETURNING *;
$$;


CREATE OR REPLACE FUNCTION pricegroups__list() RETURNS SETOF pricegroup
LANGUAGE SQL AS $$
SELECT * FROM pricegroup;
$$;



update defaults set value = 'yes' where setting_key = 'module_load_ok';

COMMIT;
