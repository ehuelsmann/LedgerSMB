package _114_upgrade_checks;

use LedgerSMB::Database::ChangeChecks;


check q|Ensure that (single) payments affect only one cash account|,
    query => q|select p.id, ac.trans_id, count(*)
  from payment p
         join payment_links pl
             on p.id = pl.payment_id
         join acc_trans ac
             on pl.entry_id = ac.entry_id
 where exists (select 1
                 from account_link al
                where ac.chart_id = al.account_id
                  and al.description in ('AR_paid', 'AP_paid'))
 group by p.id, ac.trans_id
having count(*) > 1|,
    description => q|
Your database can't be automatically migrated: Your database contains
payments which affect more than one cash account. This data can only
be caused by faulty configuration. The automated migration procedure
is not designed to handle this situation.

Please contact your LedgerSMB consultant or the LedgerSMB project
for advice on how to proceed.
|,
    on_failure => sub {
        my ($dbh, $rows) = @_;

        describe;
        confirm agree => 'Yes, I understand';
    },
    on_submit => sub {};


check q|Ensure that (batch) payments affect only one cash account|,
    query => q|select v.id, ac.trans_id, count(*)
  from voucher v
         join acc_trans ac
             on v.id = ac.voucher_id
 where v.batch_class in (3, 4, 6, 7)
   and exists (select 1
                 from account_link al
                where ac.chart_id = al.account_id
                  and al.description in ('AR_paid', 'AP_paid'))
 group by v.id, ac.trans_id
having count(*) > 1|,
    description => q|
Your database can't be automatically migrated: Your database contains
payment batches which affect more than one cash account. This data can
only be caused by faulty configuration. The automated migration procedure
is not designed to handle this situation.

Please contact your LedgerSMB consultant or the LedgerSMB project
for advice on how to proceed.|,
    on_failure => sub {
        my ($dbh, $rows) = @_;

        describe;
        confirm agree => 'Yes, I understand';
},
    on_submit => sub {};

1;

