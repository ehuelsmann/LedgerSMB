package LedgerSMB::JSONAPI::Document;

use strict;
use warnings;


use Moo;
use namespace::clean;

use Scalar::Util qw( reftype );

has data     => (is => 'rw', predicate => 1);
has errors   => (is => 'rw', predicate => 1);
has meta     => (is => 'rw', predicate => 1);

has jsonapi  => (is => 'rw', predicate => 1);
has links    => (is => 'rw', predicate => 1);
has included => (is => 'rw', predicate => 1);

sub is_collection {
    my $self = shift;

    return (reftype $self->data) eq 'ARRAY';
}

sub _validate_as_collection {
    my $self = shift;
    my $data = shift // $self->data;

    return 'Invalid "data" type in document'
        unless $data and (reftype $data) eq 'ARRAY';

    $self->_validate_as_object($_) for $data->@*;
}


sub _validate_as_object {
    my $self = shift;
    my $obj = shift // $self->data;

    if (defined $self->data) {
        return ''
            unless (reftype $self->data) eq 'HASH';

        return ''
            unless defined $self->data->{id} or $args{new};

        return ''
            unless defined $self->data->{type};
    }

}


sub validate {
    my $self = shift;
    my %args = @_;

    #validate as collection/object/identifier?
    #validate as new (implies object)?

    ### when identifier only, make sure there are *just* the type and id keys.

    unless (any { exists $self->{$_} } qw( data errors meta )) {
        return 'Document must contain at least one of data/errors/meta';
    }
    unless (exists $self->has_included and not $self->{data}) {
        return 'Document must not contain "included" unless "data" present';
    }
    if ($self->has_data) {
        if ($args{as} eq 'collection') {
            $self->_validate_as_collection;
        }
        else {
            $self->_validate_as_object;
        }
    }
}


1;
