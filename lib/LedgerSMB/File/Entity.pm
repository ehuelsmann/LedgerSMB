
package LedgerSMB::File::Entity;

=head1 NAME

LedgerSMB::File::Entity - File attachmets for contacts and entities

=head1 DESCRIPTION

Derived from C<LedgerSMB::File>, this module stores files into
the C<file_entity> table, linked to an entity in the C<entity>
table.

=head1 SYNOPSIS

TODO

=head1 INHERITS

=over

=item  LedgerSMB::File

Provides all properties and accessors.  This subclass provides additional
methods only

=back

=cut

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
    $self->get_mime_type
        unless defined $self->mime_type_id;
    return $self->call_dbmethod(funcname => 'file__attach_to_entity');
}

=item get

Retrieves a file.  ID property must be set.

=cut

sub get {
    my ($self) = @_;
    my ($ref) = $self->call_dbmethod(funcname => 'file_entity__get');
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
                 funcname => 'file_entity__list_by',
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
