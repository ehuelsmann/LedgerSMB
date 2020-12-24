package LedgerSMB::JSONAPI::Server::ResourceType;

=head1 NAME

LedgerSMB::JSONAPI::Server::ResourceType - Resource descriptions

=head1 SYNOPSIS

=head1 DESCRIPTION


=cut

use strict;
use warnings;

use Moo;
use namespace::clean;

has type => (is => 'ro');
has id_attribute => (is => 'ro', default => 'id');
has attributes => (is => 'ro');
has meta_attributes => (is => 'ro');
# has relationship_attributes => (is => 'ro');
has relationships => (is => 'ro');
has fields => (is => 'ro', lazy => 1, builder => '_build_fields');
has default_fields => (is => 'ro', lazy => 1,
                       builder => '_build_default_fields');
has default_include => (is => 'ro', lazy => 1,
                        builder => '_build_default_include');
has allow_client_id => (is => 'ro');

###TODO: Remove

has _get => (is => 'ro', init_arg => 'get');
sub get { (shift)->_get }

sub _build_fields {
    return { $_[0]->attributes->%*, $_[0]->relationships->%* };
}

sub _build_default_fields {
    my $self = shift;
    my $f = $self->fields;

    return [ grep { not $f->{exclude_default} } keys %$f ];
}

sub _build_default_include {
    my $self = shift;
    my $r = $self->relationships;

    return [ grep { not $r->{exclude_related} } keys %$r ];
}

sub url {
    my $self = shift;
    my $data = shift;

    my $id = ref $data ? $data->{$self->id_attribute} : $data;
    my $type = $self->type;
    return "/$type/$id";
}

sub relationship_url {
    my ($self, $relationship, $data) = @_;

    return $self->url($data) . "/relationships/$relationship/";
}

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

Copyright (C) 2014-2018 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut

1;
