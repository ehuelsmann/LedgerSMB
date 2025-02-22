
package LedgerSMB::File::Transaction;

=head1 NAME

LedgerSMB::File::Transaction - Manages attachments to financial transactions.

=head1 DESCRIPTION

Manages attachments to financial transactions (in 1.3, AR, AP, and GL entries)

Derived from C<LedgerSMB::File>, this module stores attachments in the
C<file_transaction> table linked to the C<transactions> table (which
itself is linked to the C<AR>, C<AP> and C<GL> tables).


=head1 INHERITS

=over

=item  LedgerSMB::File

Provides all properties and accessors.  This subclass provides additional
methods only

=cut

use Moose;
use namespace::autoclean;
extends 'LedgerSMB::File';

=back

=head1 METHODS

=over

=item attach()

Attaches or links a specific file to the given transaction.

=cut

sub attach {
    my ($self, $args) = @_;
    return $self->call_dbmethod(funcname => 'file__attach_to_tx');
}

=item attach_all_from_order({id = int})

Links all files to a specific transaction from a specific order.  Note this
only handles files that were attached to orders to start with.

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

=item get

Retrieves a file.  ID property must be set.

=cut

sub get {
    my ($self) = @_;
    my ($ref) = $self->call_dbmethod(funcname => 'file_transaction__get');
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
                 funcname => 'file_transaction__list_by',
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
