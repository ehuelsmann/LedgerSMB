package LedgerSMB::JSONAPI::Server;

=head1 NAME

LedgerSMB::JSONAPI::Server - Web service server component following {JSON:API}

=head1 SYNOPSIS

=head1 DESCRIPTION


=cut


use v5.24.0;
use strict;
use warnings;

use Moo;
use namespace::clean;

has resource_types => (is => 'ro');
has page_size      => (is => 'ro', default => 50);
has max_page_size  => (is => 'ro', default => 250);

use Encode qw(decode);
use HTTP::Headers::ActionPack::MediaType;
use HTTP::Headers::ActionPack::MediaTypeList;
use JSON::MaybeXS;
use List::Util qw(any min reductions uniq);
use Plack::Request;
use Scalar::Util qw(reftype);

my $json = JSON::MaybeXS->new( pretty => 0,
                               utf8 => 1,
                               indent => 1,
                               convert_blessed => 1,
                               allow_bignum => 1);
my $wantType = constructMT('application/vnd.api+json');


sub constructMT {
    return HTTP::Headers::ActionPack::MediaType
        ->new_from_string(shift);
}

sub constructMTList {
    return HTTP::Headers::ActionPack::MediaTypeList
        ->new_from_string(shift);
}

sub badRequest {
    return [ 400,
             [ 'Content-Type' => 'text/plain' ],
             [ shift ] ];
}

sub _validateRequestHeaders {
    my ($contentType, $accept) = @_;
    $accept //= '';

    if ($contentType) {
        my $mt = constructMT($contentType);
        return [ 400,
                 [ 'Content-Type' => 'text/plain' ],
                 [ qq{Bad request: content type $contentType provided,}
                   . q{ application/vnd.api+json expected} ] ]
            unless $wantType->types_match($mt);

        return [ 415,
                 [ 'Content-Type' => 'text/plain' ],
                 [ qq{Unsupported media type: content type $contentType }
                   . q{specifies parameters, but none allowed} ] ]
            unless $wantType->equals($mt);
    }

    my @accept_list = constructMTList($accept)->iterable;
    return [ 406,
             [ 'Content-Type' => 'text/plain' ],
             [ q{Want Accept header which matches application/vnd.api+json }
               . qq{media type without parameters (given: $accept)} ] ]
        unless any { $wantType->equals($_->[1]) } @accept_list;

    return undef;
}

sub _acquireContent {
    my ($env) = @_;
    my $content = '';
    my $len;
    my $off = 0;

    while ($len = $env->{'psgi.input'}->read($content,
                                             $env->{CONTENT_LENGTH},
                                             $off)) {
        if ($len) {
            $off += $len;
        }
        else {
            ### TODO: Generate error...
        }
    }
    return decode("UTF-8", $content);
}


sub data_to_object {
    my ($self, $data) = @_;

    return {
        data => { map { $_ => $data->{$_} }
                  grep { exists $data->{$_} }
                  $self->attributes->@* },
        links => {
            self => $self->url($data),
        },
    };
}

sub data_to_collection {
    my ($self, $data) = @_;

    return {
        data => [
            map { $_ } @$data,
            ],
        links => {
            self => $self
        }
    };
}

sub _intersect {
    my ($first, $second) = @_;

    # make sure we de-duplicate both collections values
    my %first = map { $_ => 1 } @$first;
    my %second = map { $_ => 1 } @$second;
    return grep { $second{$_} } keys %first;
}

sub _sparse_fields {
    my ($self, $req, $res) = @_;
    my @fparams = $req->query_parameters->get_all('fields['.$res->type.']');

    if (not @fparams) {
        return $res->default_fields;
    }

    return [ _intersect([ map { split /,/ } @fparams ],
                        keys $res->fields->%*) ];
}

sub _include_relationship_paths {
    my ($self, $req, $res) = @_;
    my @rparams = $req->query_parameters->get_all('include');

    if (not @rparams) {
        return $res->default_include;
    }
    return [
        map { [ split /[.]/ ] }
        uniq map { reductions { "$a.$b" } split /[.]/  }
        @rparams
        ];
}


sub _expand_tomany_relationship {
    my ($self, $rtype, $id, $env, $rel_desc) = @_;

    ...;
}

sub _expand_toone_relationship {
    my ($self, $rtype, $id, $env, $rel_desc, $data) = @_;

    my $target_type = $self->resource_types->{$rel_desc->{type}};
    return {
        links => {
            related => $target_type->url($data->{$rel_desc->{field}}),
        },
        data => {
            id => $data->{$rel_desc->{field}},
            type => $rel_desc->{type},
        }
    };
}

sub _expand_relationship {
    my $self = shift;
    my ($rtype, $id, $env, $rel_desc, $data) = @_;

    if ($rel_desc->{arity} eq 'one') {
        return $self->_expand_toone_relationship(@_);
    }
    return $self->_expand_tomany_relationship(@_);
}

sub get_resource {
    my ($self, $rtype, $id, $env) = @_; # ignore $doc
    my $req = Plack::Request->new($env);
    my $obj = $rtype->get(id => $id);
    my %atts = $obj->%{
        grep { defined $obj->{$_} }
        grep { $rtype->attributes->{$_} }
        $self->_sparse_fields($req, $rtype)->@*
        };
    my %rels = (
        map { $_->name => $self->_expand_relationship(
                  $rtype, $id, $env, $_, $obj)  }
        grep { $rtype->relationships->{$_} }
        $self->_sparse_fields($req, $rtype)->@*
        );
    my $rv = {
        data => {
            id => $obj->{$rtype->id_attribute},
            type => $rtype->type,
        },
    };
    $rv->{data}->{attributes}    = \%atts if %atts;
    $rv->{data}->{relationships} = \%rels if %rels;

    ###TODO: included resources

    return [200,
            [ 'Content-Type' => 'application/vnd.api+json' ],
            $rv];
}

sub update_resource {
    my ($self, $rtype, $id, $env, $doc) = @_;
    ...;
}

sub create_resource {
    my ($self, $rtype, $env, $doc) = @_;
    ...;
}

sub delete_resource {
    my ($self, $rtype, $id, $env, $doc) = @_;
    ...;
}

sub _validated_req {
    my $env = shift;
    my $next = shift;
    my $error;

    if ($error = _validateRequestHeaders($env->{CONTENT_TYPE},
                                         $env->{HTTP_ACCEPT})) {
        return $error;
    }

    my $request_body = _acquireContent($env);
    my $doc;
    if ($request_body) {
        my $content = $json->decode($request_body);
        unless (reftype $content eq 'HASH') {
            return badRequest('Root level must be a JSON object');
        }

        $doc = LedgerSMB::JSONAPI::Document->new(%$content);
        if ($error = $doc->validate) {
            return badRequest($error);
        }
    }

    my $rv = $next->($env, $doc);
    if ($rv->[2] and reftype $rv->[2] eq 'HASH') {
        $rv->[2] = [ $json->encode($rv->[2]) ];
    }
    return $rv;
}

sub _allocate_get_handler {
    my ($self, $r) = @_;

    return sub {
        my ($env, $names) = @_;

        if (not $names->{id}) {
            return $self->get_collection($r, $env);
        }

        return _validated_req($env, sub { $self->get_resource($r, $names->{id},
                                                            @_) });
    };
}

sub _allocate_patch_handler {
    my ($self, $r) = @_;

    return sub {
        my ($env, $names) = @_;

        if (not $names->{id}) {
            return badRequest('Resource collection cannot be PATCHed');
        }

        return _validated_req($env, sub { $self->update_resource($r, $names->{id},
                                                         @_); });
    };
}

sub _allocate_post_handler {
    my ($self, $r) = @_;

    return sub {
        my ($env, $names) = @_;

        if ($names->{id}) {
            return badRequest('Resources cannot be POSTed; must be PATCHed');
        }

        return _validated_req($env, sub { $self->create_resource($r, @_); });
    };
}


sub _allocate_delete_handler {
    my ($self, $r) = @_;

    return sub {
        my ($env, $names) = @_;

        if (not $names->{id}) {
            return forbidden('Resource collections cannot be DELETEd');
        }

        return _validated_req($env, sub { $self->delete_resource($r, @_); });
    };
}

sub _allocate_get_rel_handler {
    my ($self, $r, $rel) = @_;

    return sub {
        ...
    };
}


sub _allocate_post_rel_handler {
    my ($self, $r, $rel) = @_;

    return sub {
        ...
    };
}


sub _allocate_patch_rel_handler {
    my ($self, $r, $rel) = @_;

    return sub {
        ...
    };
}


sub _allocate_delete_rel_handler {
    my ($self, $r, $rel) = @_;

    return sub {
        ...
    };
}


sub handlers {
    my $self = shift;
    my @handlers;

    ### TODO Sub-resources?!
    for my $r ($self->resource_types->@*) {
        my $url = '/' . $r->type . '/:id';
        push @handlers, [ 'get', $url, $self->_allocate_get_handler($r) ];
        push @handlers, [ 'patch', $url, $self->_allocate_patch_handler($r) ];
        push @handlers, [ 'post', $url, $self->_allocate_post_handler($r) ];
        push @handlers, [ 'delete', $url, $self->_allocate_delete_handler($r) ];

        for my $rel (keys $r->relationships->%*) {
            my $rel_url = $url . '/relationships/' . $rel;
            push @handlers,
                [ 'get', $rel_url,
                  $self->_allocate_rel_get_handler($r, $rel) ];
            push @handlers,
                [ 'patch', $rel_url,
                  $self->_allocate_rel_patch_handler($r, $rel) ];
            push @handlers,
                [ 'post', $rel_url,
                  $self->_allocate_rel_post_handler($r, $rel) ];
            push @handlers,
                [ 'delete', $rel_url,
                  $self->_allocate_rel_delete_handler($r, $rel) ];
        }
    }
    return @handlers;
}


=head1 LICENSE AND COPYRIGHT

Copyright (C) 2014-2018 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut

1;
