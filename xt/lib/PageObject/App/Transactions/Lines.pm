package PageObject::App::Transactions::Lines;

use strict;
use warnings;

use Carp;
use PageObject;
use PageObject::App::Transactions::Line;

use Moose;
use namespace::autoclean;
extends 'PageObject';

__PACKAGE__->self_register(
              'transaction-lines',
              './/table[@id="transaction-lines"]',
              tag_name => 'table',
              attributes => {
                  id => 'transaction-lines',
              });

has transaction_type => (is => 'ro', isa => 'Str', required => 1);

sub _verify {
    my ($self) = @_;

    return $self;
}

sub line {
    my ($self, $id, %opts) = @_;

    $opts{by} //= 'id';

    if ($opts{by} eq 'id') {
        $id = 'line-' . $id;
    }
    return $self->find('*transaction-line', $opts{by} => $id,
        widget_args => [ transaction_type => $self->transaction_type ]);
}

sub all_lines {
    my ($self) = @_;

    return $self->find_all('*transaction-line',
        widget_args => [ transaction_type => $self->transaction_type ]);
}

sub empty_lines {
    my ($self) = @_;

    return grep { $_->is_empty } $self->all_lines;
}



__PACKAGE__->meta->make_immutable;

1;
