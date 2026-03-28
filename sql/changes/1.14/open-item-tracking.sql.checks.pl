package _114_uprade_checks;

use LedgerSMB::Database::ChangeChecks;

check q|Check AR/AP items associated with exactly one AR/AP ledger account.|,
    query => q|
       select id, count(distinct chart_id) as "count"
         from (select id from ar
               union all
               select id from ap) aa
              join acc_trans ac
                   on aa.id = ac.trans_id
              join account_link al
                   on ac.chart_id = al.account_id
        where al.description in ('AR','AP')
       group by id
       having count(distinct chart_id)>1
    |,
    description => q|
The upgrade process found Accounts Receivable or Accounts Payable transactions
which contain payments on more than one AR/AP ledger account. The existing
migration functionality is unable to migrate your data set.

Please contact the development team for help on migrating your data set.
|,
    on_failure => sub {
        my ($dbh, $rows) = @_;

        describe;

        confirm ok => 'I understand';
    },
    on_submit => sub {
        my ($dbh, $rows) = @_;
    }
;


1;
