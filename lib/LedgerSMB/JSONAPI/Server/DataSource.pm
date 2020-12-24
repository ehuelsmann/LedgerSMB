package LedgerSMB::JSONAPI::Server::DataSource;

=head1 NAME

LedgerSMB::JSONAPI::Server::DataSource - Data source role for JSONAPI::Server

=head1 SYNOPSIS

   package MyJSONAPI::DataSource;

   use Moo;
   with 'LedgerSMB::JSONAPI::Server::DataSource';

   sub get_resource { }

   sub get_collection { }

   ...

   1;

=head1 DESCRIPTION

This module provides an interface each JSONAPI server's data source needs to
implement.

Each data source instance provides a single resource type, meaning that each
value of the JSON:API resource identifier's C<type> field maps to an instance
implementing this role.

The resource C<data> returned and consumed by the methods in this role are
hashes. The keys in the hash correspond to the JSON:API fields in the resource.
Additionally: the special-case key C<id> maps to the resource identifier's
C<id>.

The resource data should not return a C<type> key as it will be discarded: the
C<type> and C<id> fields are disallowed by the specification.


Note that the server needs a resource description (a
C<LedgerSMB::JSONAPI::Server::Resource> instance)
to be registered for every resource. Irrespective of which fields are part
of the resource data returned by the methods in this role, will the server
never return fields to a client which aren't part of the resource description.

=head1 ERROR HANDLING


@@ to be filled

=cut

use strict;
use warnings;

use Moo::Role;
use namespace::clean;

=head1 METHODS

=head2 Resource operations

=head3 get_resource($id, $fields, %options)

Returns the resource (a hash) with the C<$fields> specified. Note that
this method is expected to return I<attributes>, I<meta 'attributes'>
as well as I<to-one relationships>. I<To-many relationships> will be
separately queried by the server and merged into the response.

The return value MAY contain more keys than specified in the C<$fields>
arrayref, however those fields listed I<must> be included. Included values
may be C<undef> unless the field is marked as I<required> in the resource
description.


=cut

requires 'get_resource';

=head3 get_collection($fields, %options)

Returns a list or arrayref (in list or scalar context respectively)
of resources with each resource value defined as if it had been returned
through C<get_resource>. C<$fields> has the same definition as for
C<get_resource>.

C<options> may contain any of these keys:

=over

=item sort (string)

Sort order as requested by the client.

@@ mention something about "sort fields" not necessarily being
aligned or in correspondance with "resource fields".

=item offset (integer)

Pagination related; the returned set must skip the first C<offset> items
in the result. This rule is to be applied I<after> the sorting rules have
been applied, if any.

=item limit (integer)

Pagination related; indicates the number of items which the server will
return to the client. Any number of items returned above and beyond C<limit>
will be discarded by the server.

=item filter (string)

@@ to be documented; reserved but unused as of now.

Application of C<offset> and C<limit> should be I<after> application of
the filtering rule specified in this key.

=item ids (ref to array of strings)

Expresses an explicit list of resources to be included in the resultset.
This key provides the first filter to be applied; the order of sorting
and filtering to be applied after that is: C<filter>, C<offset>, C<limit>.

=back


=cut

requires 'get_collection';

=head3 update_resource($id, $data)

Instructs the data source to update the resource identified by C<$id> with
the values supplied in <$data>. The fields follow the same rules as those
specified for C<get_resource>: the data may contain attributes and I<to-one>
relationships. I<to-many> relationships are handled through the C<*_tomany>
methods.

Returns C<undef> if the resource can't be found, the C<$id> if the resource
was updated, no other data was updated and no new meta data needs to be
returned or a hashref (as if C<get_resource> was called) in all other cases
where the update was performed successfully.

=cut

requires 'update_resource';

=head3 delete_resource($id)

Instructs the data source to remove the resource identified by C<$id>.

=cut

requires 'delete_resource';

=head3 create_resource($data)

Instructs the data source to create a new resource. Returns the created
resource as if C<get_resource> had been called.

=cut

requires 'create_resource';

=head2 Relationships operations

=head3 get_tomany($id, $relationship, %options)

Returns the collection of items in the relationship named C<$relationship>
as associated with resource C<$id>.

C<options> may specify the keys C<offset> and C<limit> which bear the same
meaning as specified for the options of C<get_collection>.

=cut

requires 'get_tomany';

=head3 create_tomany($id, $relationship, \@elements, %options)

Instructs the data source to add elements with C<id>s enumerated in
C<@elements> to the relationship C<$relationship> of the resource identified
by C<$id>.

In case one of the elements in C<@elements> already exists, its existence in
the list of elements to be added, will be ignored.

=cut

requires 'create_tomany';

=head3 replace_tomany($id, $relationship, \@elements)

Instructs the data source to remove the elements of the relationship
C<$relationship> associated with the resource identified by C<$id>, replacing
the elements with those enumerated in C<@elements>.

=cut

requires 'replace_tomany';

=head3 delete_tomany($id, $relationship, \@elements)

Instructs the data source to remove the elements of the relationship
C<$relationship> associated with the resource identified by C<$id>. In
case an element doesn't exist in the relationship, its existence in
C<@elements> is ignored.

=cut

requires 'delete_tomany';

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2020 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut


1;
