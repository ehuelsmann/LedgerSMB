-- To run from other transaction test scripts!

/*
========================================================================
  TEST DATA FOR RECONCILIATION TESTS
========================================================================

This file sets up three independent reconciliation scenarios, each on
its own account.  The shared cast of characters is:

  Transactions used as line sources
  ----------------------------------
  AR transactions (all approved, 10 XTS each):
    -200  1000-01-01   entity_credit -200
    -201  1000-01-03   entity_credit -200
    -204  1000-01-01   entity_credit -200
    -205  1000-01-03   entity_credit -201   ← credit account 2
    -206  1000-01-01   entity_credit -201   ← credit account 2
    -207  1000-01-03   entity_credit -201   ← credit account 2
    -208  1000-01-01   entity_credit -201   ← credit account 2
    -209  1000-01-03   entity_credit -201   ← credit account 2
    -300  1000-01-01   entity_credit -200   ← unapproved lines

  GL transactions:
    -202  1000-01-01  approved   'Recon gl test 1'
    -203  1000-01-01  approved   'Recon gl test 2'
    -210  1000-01-03  approved   'Recon gl test 3'
    -211  1000-01-03  approved   'Recon gl test 4'
    -212  1000-01-03  approved   'Cleared gl trans'           ← cleared; excluded
    -213  1000-01-03  UNAPPROVED 'Unapproved gl trans'        ← unapproved trans; excluded
    -214  1000-01-03  UNAPPROVED 'gl trans, unapproved lines' ← unapproved lines; excluded

  Payment:
    -2010 / payment id -201   1000-01-03  entity_credit -201  account -11112



========================================================================
  SCENARIO 1 — "Test Act 1"  (account -11111)
========================================================================

  This account has NO payment association.
  Reconciliation lines are therefore aggregated by (source, transdate).
  Lines without a source are listed individually (not applicable here
  since all test lines carry a source).

  acc_trans lines written to -11111:
  ┌──────────┬────────────┬──────────┬────────────────────────────────┐
  │ trans_id │ transdate  │ source   │ notes                          │
  ├──────────┼────────────┼──────────┼────────────────────────────────┤
  │  -200    │ 1000-01-01 │ '1'      │ AR                             │
  │  -204    │ 1000-01-01 │ '1'      │ AR  } aggregated together      │
  │  -206    │ 1000-01-01 │ '1'      │ AR                             │
  │  -300    │ 1000-01-01 │ '1'      │ EXCLUDED: unapproved line      │
  ├──────────┼────────────┼──────────┼────────────────────────────────┤
  │  -202    │ 1000-01-01 │ 't gl 1' │ GL  } aggregated together      │
  │  -203    │ 1000-01-01 │ 't gl 1' │ GL                             │
  ├──────────┼────────────┼──────────┼────────────────────────────────┤
  │  -208    │ 1000-01-01 │ '2'      │ AR  (sole line for source '2') │
  ├──────────┼────────────┼──────────┼────────────────────────────────┤
  │  -201    │ 1000-01-03 │ '1'      │ AR                             │
  │  -207    │ 1000-01-03 │ '1'      │ AR  } aggregated together      │
  │  -210    │ 1000-01-03 │ '1'      │ GL                             │
  │  -213    │ 1000-01-03 │ '1'      │ GL  (unapproved *trans*; line  │
  │          │            │          │      itself is approved)       │
  │  -212    │ 1000-01-03 │ '1'      │ EXCLUDED: cleared line         │
  │  -214    │ 1000-01-03 │ '1'      │ EXCLUDED: unapproved line      │
  ├──────────┼────────────┼──────────┼────────────────────────────────┤
  │  -211    │ 1000-01-03 │ 't gl 1' │ GL  (sole line for 't gl 1')   │
  ├──────────┼────────────┼──────────┼────────────────────────────────┤
  │  -209    │ 1000-01-03 │ '2'      │ AR  (sole line for source '2') │
  └──────────┴────────────┴──────────┴────────────────────────────────┘

  Expected reconciliation output (6 aggregate rows):
    1000-01-01  source '1'      amount -30   (3 lines × -10)
    1000-01-01  source 't gl 1' amount -20   (2 lines × -10)
    1000-01-01  source '2'      amount -10   (1 line)
    1000-01-03  source '1'      amount -40   (4 lines × -10)
    1000-01-03  source 't gl 1' amount -10   (1 line)
    1000-01-03  source '2'      amount -10   (1 line)


========================================================================
  SCENARIO 2 — "Test Act 2"  (account -11112)
========================================================================

  This account HAS a payment (payment id -201, date 1000-01-03).
  Reconciliation behaviour:
    • AR lines: ALL acc_trans lines linked to the payment transaction
      (on the G/L account) are collapsed into a single payment line,
      regardless of their individual transdates.
    • GL lines: included only when source matches the payment
      reference AND transdate == payment_date (1000-01-03).
      GL lines with transdate != payment_date are EXCLUDED even if
      the source matches.

  acc_trans lines written to -11112:
  ┌──────────┬────────────┬──────────┬────────────────────────────────────┐
  │ open_item_id │ transdate  │ source   │ notes                              │
  ├──────────┼────────────┼──────────┼────────────────────────────────────┤
  │  -2000    │ 1000-01-01 │ '1'      │ AR → payment_links → payment -201  │
  │  -2001    │ 1000-01-03 │ '1'      │ AR → payment_links → payment -201  │
  │  -2004    │ 1000-01-01 │ '1'      │ AR → payment_links → payment -201  │
  │           (note: -206 intentionally omitted to give -11112 a          │
  │            different row count than -11111)                           │
  │  -2008    │ 1000-01-01 │ '1'      │ AR → payment_links → payment -201  │
  │  -2005    │ 1000-01-03 │ '1'      │ AR → payment_links → payment -201  │
  │  -2007    │ 1000-01-03 │ '1'      │ AR → payment_links → payment -201  │
  │  -2009    │ 1000-01-03 │ '1'      │ AR → payment_links → payment -201  │
  ├──────────┼────────────┼──────────┼────────────────────────────────────┤
  │  -210    │ 1000-01-03 │ '1'      │ GL transdate == payment_date →     │
  │  -211    │ 1000-01-03 │ '1'      │   included in the payment line     │
  │  -213    │ 1000-01-03 │ '1'      │ GL (unapproved trans, approved line│
  │          │            │          │  transdate == payment_date)        │
  ├──────────┼────────────┼──────────┼────────────────────────────────────┤
  │  -202    │ 1000-01-01 │ '1'      │ GL EXCLUDED: transdate ≠ pay. date │
  │  -203    │ 1000-01-01 │ '1'      │ GL EXCLUDED: transdate ≠ pay. date │
  ├──────────┼────────────┼──────────┼────────────────────────────────────┤
  │  -2000    │ 1000-01-01 │ '1'      │ EXCLUDED: cleared + unapproved     │
  │  -212    │ 1000-01-03 │ '1'      │ EXCLUDED: cleared                  │
  │  -214    │ 1000-01-03 │ '1'      │ EXCLUDED: unapproved line          │
  └──────────┴────────────┴──────────┴────────────────────────────────────┘

  Expected reconciliation output (1 aggregate row):
    payment -201  date 1000-01-03  total amount = sum of all included lines

 */

CREATE OR REPLACE FUNCTION test_get_account_id(in_accno text) returns int as
  $$ SELECT id FROM account WHERE accno = $1; $$
  language sql;


INSERT INTO workflow (workflow_id, state, type)
VALUES (nextval('workflow_seq'), 'SAVED', 'whatever');


INSERT INTO account(id, accno, description, category, heading, contra)
values (-200, '-11111', 'Test Act 1', 'A',
        (select id from account_heading WHERE accno  = '000000000000000000000'), false);

INSERT INTO account(id, accno, description, category, heading, contra)
values (-201, '-11112', 'Test Act 2', 'A',
        (select id from account_heading WHERE accno  = '000000000000000000000'), false);

-- Cash Account
INSERT INTO account(id, accno, description, category, heading, contra)
values (-203, '-11123', 'Test Cash Act', 'A',
        (select id from account_heading WHERE accno  = '000000000000000000000'), false);

INSERT INTO entity (id, control_code, name, country_id)
values (-201, '-11111', 'Test 1', 242);

INSERT INTO entity_credit_account (entity_id, id, meta_number, entity_class, ar_ap_account_id, curr)
values (-201, -200, 'T-11111', 1, -1000, 'XTS');
INSERT INTO entity_credit_account (entity_id, id, meta_number, entity_class, ar_ap_account_id, curr)
values (-201, -201, 'T-11112', 1, -1000, 'XTS');


INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
VALUES (-200, '1000-01-01', 'ar', 'ar', true);
INSERT INTO open_item (id, item_number, item_type, account_id)
overriding system value
VALUES (-2000, '-2000', 'ar', test_get_account_id('-11111'));
INSERT INTO ar (trans_id, open_item_id, invnumber, amount_bc, netamount_bc, amount_tc, netamount_tc,
                entity_credit_account, curr)
values (-200, -2000, '-2000', '10', '10', 10, 10, -200, 'XTS');
INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
VALUES (-201, '1000-01-03', 'ar', 'ar', true);
INSERT INTO open_item (id, item_number, item_type, account_id)
overriding system value
VALUES (-2001, '-2001', 'ar', test_get_account_id('-11111'));
INSERT INTO ar (trans_id, open_item_id, invnumber, amount_bc, netamount_bc, amount_tc, netamount_tc,
                entity_credit_account, curr)
values (-201, -2001, '-2001', '10', '10', 10, 10, -200, 'XTS');
INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
VALUES (-204, '1000-01-01', 'ar', 'ar', true);
INSERT INTO open_item (id, item_number, item_type, account_id)
overriding system value
VALUES (-2004, '-2004', 'ar', test_get_account_id('-11111'));
INSERT INTO ar (trans_id, open_item_id, invnumber, amount_bc, netamount_bc, amount_tc, netamount_tc,
                entity_credit_account, curr)
values (-204, -2004, '-204', '10', '10', 10, 10, -200, 'XTS');
INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
VALUES (-205, '1000-01-03', 'ar', 'ar', true);
INSERT INTO open_item (id, item_number, item_type, account_id)
overriding system value
VALUES (-2003, '-2003', 'ar', test_get_account_id('-11111'));
INSERT INTO ar (trans_id, open_item_id, invnumber, amount_bc, netamount_bc, amount_tc, netamount_tc,
                entity_credit_account, curr)
values (-205, -2003, '-2003', '10', '10', 10, 10, -200, 'XTS');

INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
VALUES (-206, '1000-01-01', 'ar', 'ar', true);
INSERT INTO open_item (id, item_number, item_type, account_id)
overriding system value
VALUES (-2006, '-2006', 'ar', test_get_account_id('-11111'));
INSERT INTO ar (trans_id, open_item_id, invnumber, amount_bc, netamount_bc, amount_tc, netamount_tc,
                entity_credit_account, curr)
values (-206, -2006, '-2006', '10', '10', 10, 10, -201, 'XTS');
INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
VALUES (-207, '1000-01-03', 'ar', 'ar', true);
INSERT INTO open_item (id, item_number, item_type, account_id)
overriding system value
VALUES (-2005, '-2005', 'ar', test_get_account_id('-11111'));
INSERT INTO ar (trans_id, open_item_id, invnumber, amount_bc, netamount_bc, amount_tc, netamount_tc,
                entity_credit_account, curr)
values (-207, -2005, '-2005', '10', '10', 10, 10, -201, 'XTS');
INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
VALUES (-208, '1000-01-01', 'ar', 'ar', true);
INSERT INTO open_item (id, item_number, item_type, account_id)
overriding system value
VALUES (-2008, '-2008', 'ar', test_get_account_id('-11111'));
INSERT INTO ar (trans_id, open_item_id, invnumber, amount_bc, netamount_bc, amount_tc, netamount_tc,
                entity_credit_account, curr)
values (-208, -2008, '-2008', '10', '10', 10, 10, -201, 'XTS');
INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
VALUES (-209, '1000-01-03', 'ar', 'ar', true);
INSERT INTO open_item (id, item_number, item_type, account_id)
overriding system value
VALUES (-2009, '-2009', 'ar', test_get_account_id('-11111'));
INSERT INTO ar (trans_id, open_item_id, invnumber, amount_bc, netamount_bc, amount_tc, netamount_tc,
                entity_credit_account, curr)
values (-209, -2009, '-2009', '10', '10', 10, 10, -201, 'XTS');

INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
VALUES (-300, '1000-01-01', 'ar', 'ar', true);
INSERT INTO open_item (id, item_number, item_type, account_id)
overriding system value
VALUES (-3000, '-3000', 'ar', test_get_account_id('-11111'));
INSERT INTO ar (trans_id, open_item_id, invnumber, amount_bc, netamount_bc, amount_tc, netamount_tc,
                entity_credit_account, curr)
values (-300, -3000, '-3000', '10', '10', 10, 10, -200, 'XTS');


insert into transactions (id, table_name, transdate, approved, reference, trans_type_code, workflow_id)
            overriding system value
values (-2010, 'payment', '1000-01-03', true, 'reference-test', 'pa', null --###BUG: need workflow_id
  );
insert into payment (trans_id, id, reference, payment_class, payment_date, entity_credit_id, currency, account_id)
values (-2010, -201, 'reference-test', 2, '1000-01-03', -201, 'XTS', test_get_account_id('-11123'));


insert into transactions (id, table_name, transdate, approved, reference, trans_type_code, workflow_id)
            overriding system value
values (-2011, 'payment', '1000-01-03', false, 'reference-test2', 'pa', null --###BUG: need workflow_id
  );
insert into payment (trans_id, id, reference, payment_class, payment_date, entity_credit_id, currency, account_id)
values (-2011, -202, 'reference-test2', 2, '1000-01-03', -201, 'XTS', test_get_account_id('-11123'));


INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
            values (-202, '1000-01-01', 'gl', 'gl', true);
INSERT INTO gl (id, reference) values (-202, 'Recon gl test 1');
INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
            values (-203, '1000-01-01', 'gl', 'gl', true);
INSERT INTO gl (id, reference) values (-203, 'Recon gl test 2');
INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
            values (-210, '1000-01-03', 'gl', 'gl', true);
INSERT INTO gl (id, reference) values (-210, 'Recon gl test 3');
INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
            values (-211, '1000-01-03', 'gl', 'gl', true);
INSERT INTO gl (id, reference) values (-211, 'Recon gl test 4');

INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
            values (-212, '1000-01-03', 'gl', 'gl', true);
INSERT INTO gl (id, reference)
values (-212, 'Cleared gl trans');
INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
            values (-213, '1000-01-03', 'gl', 'gl', false);
INSERT INTO gl (id, reference)
values (-213, 'Unapproved gl trans');
INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
            values (-214, '1000-01-03', 'gl', 'gl', false);
INSERT INTO gl (id, reference)
values (-214, 'gl trans, unapproved lines');


-- Test Act 1; 1000-01-01; source '1'
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-200, test_get_account_id('-11111'), '1000-01-01', -10, 'XTS', -10, '1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-204, test_get_account_id('-11111'), '1000-01-01', -10, 'XTS', -10, '1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-206, test_get_account_id('-11111'), '1000-01-01', -10, 'XTS', -10, '1');
-- not approved, so not included
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source, cleared, approved)
values (-300, test_get_account_id('-11111'), '1000-01-01', -10, 'XTS', -10, '1', true, false);

-- Test Act 1; 1000-01-01; source 't gl 1'
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-202, test_get_account_id('-11111'), '1000-01-01', -10, 'XTS', -10,'t gl 1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-203, test_get_account_id('-11111'), '1000-01-01', -10, 'XTS', -10,'t gl 1');

-- Test Act 1; 1000-01-01; source '2'
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-208, test_get_account_id('-11111'), '1000-01-01', -10, 'XTS', -10,'2');


-- Test Act 1; 1000-01-03; source '1' (both AR and GL lines)
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-201, test_get_account_id('-11111'), '1000-01-03', -10, 'XTS', -10, '1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-207, test_get_account_id('-11111'), '1000-01-03', -10, 'XTS', -10, '1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-210, test_get_account_id('-11111'), '1000-01-03', -10, 'XTS', -10, '1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source, cleared)
values (-213, test_get_account_id('-11111'), '1000-01-03', -10, 'XTS', -10, '1', false);
-- Don't include cleared or unapproved transactions
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source, cleared)
values (-212, test_get_account_id('-11111'), '1000-01-03', -10, 'XTS', -10, '1', true);
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source, approved)
values (-214, test_get_account_id('-11111'), '1000-01-03', -10, 'XTS', -10, '1', false);


-- Test Act 1; 1000-01-03; source 't gl 1'
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-211, test_get_account_id('-11111'), '1000-01-03', -10, 'XTS', -10,'t gl 1');

-- Test Act 1; 1000-01-03; source '2'
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-209, test_get_account_id('-11111'), '1000-01-03', -10, 'XTS', -10, '2');


-- Test Act 2; presented as a single line,
--   because all part of the same payment (AR)
--   or with the same source and transdate==payment_date (GL)

/* AR lines; not adding open items, because cash accounts aren't open item managed... */
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-2010, test_get_account_id('-11112'), '1000-01-01', 10, 'XTS', 10, '1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-2010, test_get_account_id('-11112'), '1000-01-03', 10, 'XTS', 10, '1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-2010, test_get_account_id('-11112'), '1000-01-01', 10, 'XTS', 10, '1');
-- id -206 intentionally left out to create a different number of rows in accounts -11111 and -11112
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-2010, test_get_account_id('-11112'), '1000-01-01', 10, 'XTS', 10,'1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-2010, test_get_account_id('-11112'), '1000-01-03', 10, 'XTS', 10, '1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-2010, test_get_account_id('-11112'), '1000-01-03', 10, 'XTS', 10, '1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-2010, test_get_account_id('-11112'), '1000-01-03', 10, 'XTS', 10,'1');

/* GL lines */
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-210, test_get_account_id('-11112'), '1000-01-03', 10, 'XTS', 10, '1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-211, test_get_account_id('-11112'), '1000-01-03', 10, 'XTS', 10,'1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-213, test_get_account_id('-11112'), '1000-01-03', 10, 'XTS', 10, '1');
-- Don't include GL transactions with the same source, but with a transdate unequal to the payment_date
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-202, test_get_account_id('-11112'), '1000-01-01', 10, 'XTS', 10,'1');
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-203, test_get_account_id('-11112'), '1000-01-01', 10, 'XTS', 10,'1');


-- Don't include cleared or unapproved transactions
select reconciliation__new_report(test_get_account_id('-11112'), 10, '1000-01-04', false,
                                  (select currval('workflow_seq')));
insert into cr_report_line (report_id, scn, their_balance, our_balance, "user", trans_type, cleared)
values (currval('cr_report_id_seq'), 'test', 10, 10, (select entity_id from users limit 1), '', true);
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source, cleared, approved)
values (-2011, test_get_account_id('-11112'), '1000-01-01', 10, 'XTS', 10, '1', true, false);
insert into cr_report_line_links (report_line_id, entry_id, cleared)
values (currval('cr_report_line_id_seq'), currval('acc_trans_entry_id_seq'), true);
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source, cleared)
values (-212, test_get_account_id('-11112'), '1000-01-03', 10, 'XTS', 10, '1', true);
insert into cr_report_line_links (report_line_id, entry_id, cleared)
values (currval('cr_report_line_id_seq'), currval('acc_trans_entry_id_seq'), true);
INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source, approved)
values (-214, test_get_account_id('-11112'), '1000-01-03', 10, 'XTS', 10, '1', false);
update cr_report set submitted = true where id = currval('cr_report_id_seq');
update cr_report set approved = true where id = currval('cr_report_id_seq');


-- Test Act 3 - 2 payments and an adjustment, all with the same source

INSERT INTO account(id, accno, description, category, heading, contra)
values (-202, '-11113', 'Test Act 3', 'A',
        (select id from account_heading WHERE accno  = '000000000000000000000'), false);


INSERT INTO entity (id, control_code, name, country_id)
values (-202, '-11113', 'Test 1', 242);
INSERT INTO entity_credit_account (entity_id, id, meta_number, entity_class, ar_ap_account_id, curr)
values (-202, -202, 'T-11113', 1, -1000, 'XTS');


INSERT INTO transactions (transdate, table_name, trans_type_code, approved)
            values ('1000-01-01', 'payment', 'pa', true);
insert into payment (trans_id, id, reference, payment_class, payment_date, entity_credit_id, currency, account_id)
values (currval('transactions_id_seq'), -220, 'equal-reference', 2, '1000-01-01', -202, 'XTS', test_get_account_id('-11123'));

INSERT INTO transactions (transdate, table_name, trans_type_code, approved)
            values ('1000-01-01', 'payment', 'pa', true);
insert into payment (trans_id, id, reference, payment_class, payment_date, entity_credit_id, currency, account_id)
values (currval('transactions_id_seq'), -221, 'equal-reference', 2, '1000-01-01', -202, 'XTS', test_get_account_id('-11123'));


INSERT INTO transactions (id, transdate, table_name, trans_type_code, approved)
            values (-220, '1000-01-01', 'gl', 'gl', true);
INSERT INTO gl (id, reference) values (-220, 'Recon adjustment test (act 3)');


INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-200, test_get_account_id('-11113'), '1000-01-01', 10, 'XTS', 10, '1');

INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-201, test_get_account_id('-11113'), '1000-01-01', 10, 'XTS', 10, '1');


INSERT INTO acc_trans (trans_id, chart_id, transdate, amount_bc, curr, amount_tc,  source)
values (-220, test_get_account_id('-11113'), '1000-01-01', 10, 'XTS', 10, '1');

