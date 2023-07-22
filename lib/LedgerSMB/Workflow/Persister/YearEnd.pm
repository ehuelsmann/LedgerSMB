package LedgerSMB::Workflow::Persister::YearEnd;

=head1 NAME

LedgerSMB::Workflow::Persister::YearEnd - Persist year-end workflows

=head1 DESCRIPTION

This module persists year-end workflow data. On top of that, it adds
helpers to fetch workflows from the date-sequence.

The class inherits from LedgerSMB::Workflow::Persister::ExtraData; users are
expected to declare the C<transactions> table and fields as "ExtraData"
configuration.

=head1 METHODS

=cut


use warnings;
use strict;
use base qw( LedgerSMB::Workflow::Persister::ExtraData );

use Carp qw(croak);

=head2 previous_yearend_id( $wf, include_reversed => $bool )



=cut

sub previous_yearend_id {
    my ($self, $wf, %args) = @_;
    my $dbh = $self->handle;
    my $query = q|
      SELECT workflow_id
        FROM workflow w
             JOIN transactions t
                  on w.workflow_id = t.workflow_id
             JOIN yearend y
                  on t.id = y.trans_id
       WHERE t.transdate < ?
             AND (? OR not y.reversed)
       ORDER BY t.transdate DESC, trans_id DESC
       LIMIT 1
       |;

    my $sth = $dbh->prepare($query)
        or die $dbh->errstr;
    $sth->execute( $wf->context->param( 'transdate' ),
                   $args{include_reversed} )
        or die $sth->errstr;
    my ($id) = $sth->fetchrow_array();
    die $sth->errstr if $sth->err;

    return $id;
}

1;

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2023 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

