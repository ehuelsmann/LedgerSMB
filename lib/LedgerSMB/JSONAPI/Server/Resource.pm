package LedgerSMB::JSONAPI::Server::Resource;

=head1 NAME

LedgerSMB::JSONAPI::Server::Resource - JSON:API resource description

=head1 SYNOPSIS

=head1 DESCRIPTION

Instances of this class describe a JSON:API resource type.


=cut

use strict;
use warnings;

use Moo;
use namespace::clean;

=head1 ATTRIBUTES

=head2 type

=cut

has type => (is => 'ro');

=head2 id_attribute

=cut

has id_attribute => (is => 'ro', default => 'id');

=head2 attributes

=cut

has attributes => (is => 'ro');

=head2 meta_attributes

=cut

has meta_attributes => (is => 'ro');

=head2 relationships

=cut

# has relationship_attributes => (is => 'ro');
has relationships => (is => 'ro');


=head1 METHODS

=head2 url

=cut

sub url {
    my $self = shift;
    my $data = shift;

    my $id = $data->{$self->id_attribute};
    my $type = $self->type;
    return "/$type/$id"
}

=head2 relationship_url

=cut

sub relationship_url {
    my ($self, $relationship, $data) = @_;

    return $self->url($data) . "/relationships/$relationship/";
}

=head2 urls

=cut

sub urls {
    my $self = shift;

    my $type = $self->type;
    my $rel_base = "/$type/{id}/relationships/";
    my @urls = (
        "/$type/{id}",
        (map { $rel_base . $_ } keys $self->relationships->%*),
        );
    return wantarray ? @urls : \@urls;
}

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2020 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut

1;
