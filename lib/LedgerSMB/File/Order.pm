
package LedgerSMB::File::Order;

=head1 NAME

LedgerSMB::File::Order - Manages attachments to orders.

=head1 DESCRIPTION

Manages attachments to orders (sales orders, purchase orders,
quotations and RFQ's).

Derived from C<LedgerSMB::File>, this module stores files in the
C<file_order> table with links to the C<oe> table storing orders
and quotations.

=head1 INHERITS

=over

=item  LedgerSMB::File

Provides all properties and accessors.  This subclass provides additional
methods only

=back

=cut

use LedgerSMB::File::Transaction;

use Moose;
use namespace::autoclean;
extends 'LedgerSMB::File';

=head1 METHODS

=over

=item attach

Attaches or links a specific file to the given transaction.

=cut

sub attach {
    my ($self, $args) = @_;
    return $self->call_dbmethod(funcname => 'file__attach_to_order');
}

=item attach_all_from_order({id = int})

Links all files to a specific transaction from a specific order.  Note this
only handles files that were attached to orders and transactions to start with.

=cut

sub attach_all_from_order {
    my ($self, $args) = @_;
    for my $attach ($self->list({ref_key => $args->{int}, file_class => 2})){
        my $new_link = LedgerSMB::File::Transaction->new();
        $new_link->merge($attach);
        $new_link->dbobject($self->dbobject);
        $new_link->attach;
    }
    return;
}

=item attach_all_from_transaction({id = int})

Links all files to a specific transaction from a specific transaction.  Note
this only handles files that were attached to orders and transactions to start
with.

=cut

sub attach_all_from_transaction {
    my ($self, $args) = @_;
    for my $attach ($self->list({ref_key => $args->{int}, file_class => 1})){
        my $new_link = LedgerSMB::File::Transaction->new();
        $new_link->merge($attach);
        $new_link->dbobject($self->dbobject);
        $new_link->attach;
    }
    return;
}

=item get

Retrieves a file.  ID property must be set.

=cut

sub get {
    my ($self) = @_;
    my ($ref) = $self->call_dbmethod(funcname => 'file_order__get');
    $self->{$_} = $ref->{$_} for keys %$ref;
    return;
}

=item list( $id )

Returns a list of files directly attached to the object. No content is
returned.

Returns an array of hashrefs, each representing a file and comprising:

  * id
  * uploaded_by_id    # entity_id of the user who uploaded the file
  * uploaded_by_name  # entity name of the user who uploaded the file
  * file_name
  * description
  * uri               # in case this file contains a uri reference
  * uploaded_at       # date/time string YYYY-MM-DD HH:MM:SS.ssssss

=cut

sub list{
    my ($self, $arg) = @_;
    my @results = $self->call_procedure(
                 funcname => 'file_order__list_by',
                      args => [ $arg ]
     );
    return @results;
}

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2011 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut

__PACKAGE__->meta->make_immutable;
1;
