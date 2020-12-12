package LedgerSMB::Company::Configuration::Part;

=head1 NAME

LedgerSMB::Company::Configuration::Part - Part invoice item (tracking)

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

Configuration of goods and services Part (inventory-tracking invoice
item, non-assembly).

Read-write fields are synced back to the database by calling the C<save>
method.

=cut


use warnings;
use strict;

use Log::Any qw($log);

use Moose;
use namespace::autoclean;
with 'PGObject::Simple::Role';

=head1 ATTRIBUTES

=head2 id

Internal identification of the part. Read-only.

=cut

has id => (is => 'rw', reader => 'id', writer => '_id');


=head2 partnumber (required)

User defined number identifying the part. Must be unique. Read-only.

=cut

has partnumber => (is => 'ro', required => 1);

=head2 description

One-line description of the part. Read-write.

=cut

has description => (is => 'rw');

=head2 notes

Multi-line description/remarks of the part. Read-write.

=cut

has notes => (is => 'rw');

=head2 expense_accno_id


=cut

has expense_accno_id => (is => 'ro', default => 0);

=head2 income_accno_id


=cut

has income_accno_id => (is => 'ro', default => 0);

=head2 inventory_accno_id


=cut

###TODO: rw/ro: rw poses a challenge to move posted inventory around..
has inventory_accno_id => (is => 'ro', default => 0);

=head2 listprice

=cut

has listprice => (is => 'rw', default => 0);

=head2 sellprice


=cut

has sellprice => (is => 'rw', default => 0);

=head2 lastcost


=cut

has lastcost => (is => 'rw', default => 0);

=head2 updated


=cut

###TODO: named 'priceupdate' in the parts table!!!
has updated => (is => 'rw');

=head2 unit


=cut

has unit => (is => 'rw');

=head2 weight


=cut

has weight => (is => 'rw');

=head2 bin


=cut

has bin => (is => 'rw');

=head2 rop


=cut

has rop => (is => 'rw');

=head2 rop


=cut

has rop => (is => 'rw');

=head2 obsolete


=cut

has obsolete => (is => 'rw', default => 0);

=head2 partsgroup_id


=cut

has partsgroup_id => (is => 'rw');

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

    ###TODO: implement part deletion function!!!
    $self->call_dbmethod(funcname => 'part__delete');
}

=head2 save

Saves a created or changed account into the company configuration.

=cut

sub save {
    my $self = shift;

    $log->infof('Saving part %s (%s)', $self->partnumber, $self->description);
    my ($row) = $self->call_dbmethod(funcname => 'parts__save_good');
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
