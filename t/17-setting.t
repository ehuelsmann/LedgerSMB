
use Test2::V0;
use LedgerSMB::Setting;
use LedgerSMB::App_State;

{
  no warnings 'redefine';
  no strict 'refs'; # avoiding adding more dependencies
                    # so doing mocking by hand

  # Check that it uses that database handle to run the query
  local *{"PGObject::call_procedure"} = sub {
    my ($self, %args) = @_;
    ok(1, 'Called "call_procedure"');
    is($args{dbh}, 'db', 'Mocked dbh in use');
    return ({setting_key => 'database', value => '123'})
  };

  use strict 'refs';
  use warnings 'redefine';

  is(LedgerSMB::Setting->new(dbh => 'db')->get('database'), '123', 'got mocked value back');
}

done_testing;

