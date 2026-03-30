--- yaml frontmatter
title: Records in 'transactions' have an associated record in a specialization table (ar/ap/...)
description: |
  The 'transactions' is the main transactions table; transactions can be of a multitude
  of subtypes (ar/ap/...) and can never be stand-alone.
  This leaves open the possibility that a record exists in the 'transactions'
  table where no associated record exists in any of the other tables. This situation
  should not exist.
---

select id
  from transactions t
 where not exists (select 1 from ar where ar.trans_id = t.id)
   and not exists (select 1 from ap where ap.trans_id = t.id)
   and not exists (select 1 from gl where gl.id = t.id)
   and not exists (select 1 from mfg_lot where mfg_lot.id = t.id)
   and not exists (select 1 from asset_report where asset_report.id = t.id)
   and not exists (select 1 from inventory_report where inventory_report.id = t.id)
   and not exists (select 1 from payment where payment.id = t.id)
   and not exists (select 1 from yearend where yearend.trans_id = t.id)
