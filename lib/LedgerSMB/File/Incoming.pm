
package LedgerSMB::File::Incoming;

=head1 NAME

LedgerSMB::File::Incoming - Queue for to-be-classified files

=head1 DESCRIPTION

Implements a queue or store for files which haven't been classified
as attachments to transactions, customers, etc, nor have been marked
as internal files.

Derived from C<LedgerSMB::File>, stores unclassified file data in
the C<file_incoming> table.

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
    return $self->call_dbmethod(funcname => 'file__save_incoming');
}

=item get

Retrieves a file.  ID property must be set.

=cut

sub get {
    my ($self) = @_;
    my ($ref) = $self->call_dbmethod(funcname => 'file_incoming__get');
    $self->{$_} = $ref->{$_} for keys %$ref;
    return;
}

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2011-2014 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut

__PACKAGE__->meta->make_immutable;
1;
