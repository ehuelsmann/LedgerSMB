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

sub _verify {
    my ($self) = @_;

    ###TODO

    return $self;
};

my %field_map = (
    'Amount' => 'amount',
    'Account' => 'AR_amount',
    'Description' => 'description',
    'Tax Form Applied' => 'taxformcheck',
    );

sub field {
    my ($self, $label) = @_;

    my $id = $self->get_attribute('id');
    $id =~ s/^line-//;
    return $self->find(qq{.//*[\@id="$field_map{$label}_${id}"]});
}

sub field_value {
    my ($self, $label, $new_value) = @_;

    my $id = $self->get_attribute('id');
    $id =~ s/^line-//;

    if ($id eq 'total') {
        # special handling of the total line
        my %field_map = (
            'Amount' => 'amount-total',
            'Account' => 'AR',
            );

        die "Unavailable field requested: total $label"
            unless exists $field_map{$label};
        my $field = $self->find(qq{.//*[\@id="$field_map{$label}"]
                                | .//input[\@type="hidden" and
                                \@name="$field_map{$label}"]});
        return $field->can('value') ? $field->value : $field->get_text;
    }

    my $field = $self->find(qq{.//*[\@id="$field_map{$label}_${id}"]
           | .//input[\@type="hidden" and
                      \@name="$field_map{$label}_${id}"]});
    die "Transaction line column $field_map{$label}_${id} not found"
        if not defined $field;
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
