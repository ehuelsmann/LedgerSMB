package PageObject::App::Transactions::Line;

use strict;
use warnings;

use Carp;
use PageObject;


use Moose;
use namespace::autoclean;
extends 'PageObject';

use PageObject::App;

__PACKAGE__->self_register(
              'transaction-line',
              './/tr[contains(@class,"transaction-line")]',
              tag_name => 'tr',
              classes => ['transaction-line'],
    );

has transaction_type => (is => 'ro', isa => 'Str', required => 1);

sub _verify {
    my ($self) = @_;

    ###TODO

    return $self;
};


sub field {
    my ($self, $label) = @_;

    my %field_map = (
        'Amount' => 'amount',
        'Account' => ($self->transaction_type . '_amount'),
        'Description' => 'description',
        'Tax Form Applied' => 'taxformcheck',
    );


    my $id = $self->get_attribute('id');
    $id =~ s/^line-//;

    my $field = $self->find(qq{.//*[\@id="$field_map{$label}_${id}"]});
    die "Transaction line column $field_map{$label}_${id} not found"
        if not defined $field;
    return $field;
}

sub field_value {
    my ($self, $label, $new_value) = @_;

    my $id = $self->get_attribute('id');
    $id =~ s/^line-//;

    if ($id eq 'total') {
        # special handling of the total line
        my %field_map = (
            'Amount' => 'amount-total',
            'Account' => $self->transaction_type,
            );

        die "Unavailable field requested: total $label"
            unless exists $field_map{$label};
        my $field = $self->find(qq{.//*[\@id="$field_map{$label}"]
                                | .//input[\@type="hidden" and
                                \@name="$field_map{$label}"]});
        return $field->can('value') ? $field->value : $field->get_text;
    }

    my $field = $self->field($label);
    my $rv = $field->value;

    $rv = ''
        if ($field->tag_name eq 'input'
            && $field->get_attribute('type') eq 'checkbox'
            && ! $field->selected);

    if (defined $new_value) {
        $field->click;
        $field->clear if $field->can('clear');
        $field->send_keys($new_value);
    }

    return $rv;
}

sub is_empty {
    my ($self) = @_;
    return ($self->field_value('Amount') == 0);
}


__PACKAGE__->meta->make_immutable;

1;
