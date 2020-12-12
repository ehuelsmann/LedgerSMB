package LedgerSMB::Company::Configuration::Assembly;

=head1 NAME

LedgerSMB::Company::Configuration::Assembly - Assembly invoice item (tracking)

=head1 SYNOPSIS

   use LedgerSMB::Database;
   use LedgerSMB::Company;

   my $dbh = LedgerSMB::Database->new( connect_data => { ... })
       ->connect;
   my $c   = LedgerSMB::Company->new(dbh => $dbh)->configuration;
   my $h   = $c->parts->get(by => (partnumber => 'P-12'));
   my $ovh = $c->parts->create(type        => 'overhead',
                               partnumber  => 'O-01',
                               description => 'Management overhead',
                               );
   $ovh->save;

=head1 DESCRIPTION

Configuration of goods and services Assembly (inventory-tracking invoice
item, assembled/produced).

Read-write fields are synced back to the database by calling the C<save>
method.

=cut


use warnings;
use strict;

use Log::Any qw($log);

use Moose;
use namespace::autoclean;
extends 'LedgerSMB::Company::Configuration::Part';

=head1 ATTRIBUTES

None (for now) other than those inhertited from Part.

=head1 CONSTRUCTOR ARGUMENTS

In addition to the attributes from the previous section, the following
named arguments can (or even must) be provided to the C<new> constructor.

=head2 dbh (required)

The database access handle. This is provided upon instantiation by the
C<LedgerSMB::Company::Configuration::COANodes> collection.

=head1 METHODS

=head2 delete

Deletes the part. Note that this function cannot succesfully complete
when the part is being referenced in invoices, inventory or other configuration
items.

=cut

sub delete {
    my $self = shift;

    $self->call_dbmethod(funcname => 'parts__delete');
}

=head2 save

Saves a created or changed account into the company configuration.

=cut

sub save {
    my $self = shift;

    $log->infof('Saving part %s (%s)', $self->partnumber, $self->description);
    my ($row) = $self->call_dbmethod(funcname => 'parts__save_part');
    return $self->_id($row->{id});
}

=head2 onhand

=cut

sub onhand {
    ...;
}

=head2 avgcost

=cut

sub avgcost {
    ...;
}

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2020 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut

__PACKAGE__->meta->make_immutable;

1;
