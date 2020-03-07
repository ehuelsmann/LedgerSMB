=head1 NAME

LedgerSMB::DBObject::EOY - End of Year handling module

=head1 SYNOPSYS

This class contains methods for end of year entry.

=head1 BASIC PROPERTIES

=over

=item end_date specifies the end date for a closed period.

=item reference specifies the gl reference field associated with the account
closure

=item description specifies the gl description field associated with the account
closure

=item retention_acc_id specifies the account id used as a retaining account.

=back

=head1 METHODS

=over

=cut

package LedgerSMB::DBObject::EOY;
use Moose;
with 'LedgerSMB::PGObject';
use namespace::autoclean;
use strict;
use warnings;

=item $eoy->checkpoint_only($date);

This creates account checkpoints at $eoy->{end_date}.  This has two uses:
1)  Can be used to "close" books without zeroing income/expense accounts.  This
prevents data from being inserted for earlier dates.

2)  This can be used to improve performance by creating a "lookback" point.

=cut

sub checkpoint_only {
    my ($self, $date) = @_;
    $self->call_dbmethod(funcname => 'eoy_create_checkpoint',
                         args => { end_date => $date });
}

=item $eoy->reopen_books($date)

This reverses any end of year transaction on $date, and deletes
checkpoints later than that and creates a checkpoint for the prior day.

=cut

sub reopen_books {
    my ($self, $date) = @_;
    $self->call_dbmethod(funcname => 'eoy__reopen_books_at',
                         args => { reopen_date => $date });
}

=item $eoy->latest_closing()

Needs no properties set (other than internal private ones).  Retrieves the
latest closing date and returns it.

=cut

sub latest_closing {
    my ($self) = @_;
    my ($ref) = $self->call_dbmethod(funcname => 'eoy__latest_checkpoint');
    return $ref->{end_date};
}

=item $eoy->close_books($date, $reference_text, $description, $acc_id)

This creates a gl
yearend transaction, and moves income/expenses to the selected equity account
for retained earnings.

=cut

sub close_books {
    my ($self, $date, $reference_text, $description, $acc_id) = @_;
    $self->call_dbmethod(funcname => 'eoy_close_books',
                         args => {
                             end_date => $date,
                             reference => $reference_text,
                             description => $description,
                             retention_acc_id => $acc_id
                         });
}

=item $eoy->list_earnings_accounts

Returns a list of equity accounts, alist of hashrefs.  These are used
to select retained earnings accounts in closing books.

=cut

sub list_earnings_accounts{
    my ($self) = @_;
    return $self->call_dbmethod(funcname => 'eoy_earnings_accounts');
}


__PACKAGE__->meta->make_immutable;

1;

=back

=head1 COPYRYIGHT

Copyright (C) 2009-2020 The LedgerSMB Core Team.  This may be re-used as permitted by
the GNU General Public License v 2 or at your option any later version.  Please
see included License.txt for details.
