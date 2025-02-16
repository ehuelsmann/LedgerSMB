
package LedgerSMB::File;

=head1 NAME

LedgerSMB::File - Provides routines for managing file attachments.

=head1 DESCRIPTION

This provides routines for managing file attachments.  Subclasses may be used
to provide functionality for specific types of file attachments.

=head1 PROPERTIES/ACCESSORS

=over

=cut


use strict;
use warnings;

use Moose;
use namespace::autoclean;
with 'LedgerSMB::PGObject';

use File::Temp;
use Log::Any;
use MIME::Types;
use PGObject::Type::ByteString;
use LedgerSMB::Magic qw( FC_PART );
use LedgerSMB::MooseTypes;


PGObject::Type::ByteString->register(registry => 'default');

=item  uploaded_by

Entity id of the individual who attached the file.

=cut

has uploaded_by => (is => 'rw', isa => 'Maybe[Int]');

=item uploaded_by_name

Entity name of individual who attached file

=cut

has uploaded_by_name => (is => 'rw', isa => 'Maybe[Str]');

=item uploaded_at

Timestamp of attachment point.

=cut

has uploaded_at => (is => 'ro', isa => 'Maybe[LedgerSMB::Moose::Timestamp]');

=item content

This property yields a reference to the binary content of the file.
Dereferencing it will yield the underlying raw content.

When setting, either a string, or a scalar reference to a string
may be used, either of which will be coerced into a reference.

Note: Important difference with the 1.4 series is that before
  1.5.0 this attribute stored the actual content instead of a
  string reference.

=cut

has content => (is => 'rw', isa => 'LedgerSMB::Moose::FileContent',
                coerce => 1);


=item mime_type_id

ID of the MIME type.  Undef if unknown.

=cut

has mime_type_id => (is => 'rw', isa => 'Maybe[Int]');

=item mime_type_text

Standard text code of the MIME type

=cut

has mime_type_text => (is => 'rw', isa => 'Maybe[Str]');

=item file_name

File name, user specified

=cut

has file_name => (is => 'rw', isa => 'Str');

=item description

Description, user specified

=cut

has description => (is => 'rw', isa => 'Maybe[Str]');

=item id

ID of file.  undef if unknown

=cut

has id => (is => 'rw', isa => 'Maybe[Int]');

=item ref_key

Referential key for the file to attach to.

=cut

has ref_key => (is => 'rw', isa => 'Int');

=item reference

Reference control code (text string) for attached financial database object.

=cut

has reference => (is => 'rw', isa => 'Maybe[Str]');

=item file_class

ID of the file class.

=cut

has file_class => (is => 'rw', isa => 'Int');

=item src_class

ID of class of the original attachment point (for a link)

=cut

has src_class => (is => 'rw', isa => 'Maybe[Int]');

=item file_path

Path where file data is stored (for LaTeX use of attached images).

The path is a temporary path which is cleaned up as soon as this
instance goes out of scope.

=cut

has file_path => (
    is => 'ro',
    isa => 'Maybe[Str]',
    lazy => 1,
    default => sub {
        my $self = shift;
        $self->_tempdir->dirname;
    },
);

=back

=cut

my $logger = Log::Any->get_logger(category => 'LedgerSMB::File');

=head1 METHODS

=over

=item get_mime_type

Sends the textual representation of the MIME type.  If not set, retrieves and
sets it.

=cut

sub get_mime_type {
    my ($self) = @_;
    if (!($self->mime_type_id || $self->mime_type_text)){
       $self->mime_type_text(
            MIME::Types->new->mimeTypeOf($self->file_name)->type
       );
    }
    if (!($self->mime_type_id && $self->mime_type_text)){
       my ($ref) = $self->call_dbmethod(funcname => 'file__get_mime_type');
       $self->mime_type_text($ref->{mime_type});
       $self->mime_type_id($ref->{id});
    }
    return $self->mime_type_text;
}

=item get

Retrieves a file.  ID and file_class properties must be set.

=cut

sub get {
    my ($self) = @_;
    my ($ref) = $self->call_dbmethod(funcname => 'file__get');
    $self->{$_} = $ref->{$_} for keys %$ref;
    return;
}

=item get_by_name

Retrieves a file.  name, ref_key and file_class properties must be set.

=cut

sub get_by_name {
    my ($self) = @_;
    my ($ref) = $self->call_dbmethod(funcname => 'file__get_by_name');
    $self->{$_} = $ref->{$_} for keys %$ref;
    return;
}

=item remove

Deletes a file.  ID and file_class properties must be set.

=cut

sub remove {
    my ($self) = @_;
    $self->call_dbmethod(funcname => 'file__delete');
    return;
}

=item list({ref_key => int, file_class => int})

Returns a list of files directly attached to the object. No content is
returned, except for files with a mime type of 'text/x-uri'

Returns an array of hashrefs, each representing a file and comprising:

  * id
  * uploaded_by_id    # entity_id of the user who uploaded the file
  * uploaded_by_name  # entity name of the user who uploaded the file
  * file_name
  * description
  * content           # Reference to content, undef unless mime_type='text/x-uri'
  * mime_type         # The normalised mime type (e.g. 'text/plain')
  * file_class
  * ref_key
  * uploaded_at       # date/time string YYYY-MM-DD HH:MM:SS.ssssss

=cut

sub list{
    my ($self, $args) = @_;
    my @results = $self->call_procedure(
                 funcname => 'file__list_by',
                      args => [$args->{ref_key}, $args->{file_class}]
     );
    return @results;
}

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2011-2018 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut

__PACKAGE__->meta->make_immutable;

1;
