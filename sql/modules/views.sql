
set client_min_messages = 'warning';


BEGIN;

drop view if exists transactions_reversal cascade;

create view transactions_reversal as
  select t.*,
         i.id as reversed_by, i.reference as reversed_by_reference,
         j.reference as reversing_reference
    from transactions t
           left join transactions i
             on t.id = i.reversing
           left join transactions j
               on t.reversing = j.id;

update defaults set value = 'yes' where setting_key = 'module_load_ok';

COMMIT;
