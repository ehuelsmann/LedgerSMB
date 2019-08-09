package PageObject::App::Transaction;

use strict;
use warnings;

use Carp;
use PageObject;
use PageObject::App::Transactions::Lines;
use PageObject::App::Invoices::Header;
#use PageObject::App::Invoices::Payments;

use Moose;
use namespace::autoclean;
extends 'PageObject';


sub update {
    my ($self) = @_;

    $self->find("*button", text => "Update")->click;
    $self->session->page->body->maindiv->wait_for_content;
}

sub _counterparty {
    return 'customer';
}

sub header {
    my ($self) = @_;

    $self->verify;
    return $self->find('*invoice-header',
                       widget_args => [ counterparty_type => $self->_counterparty ]);
}

sub lines {
    my ($self) = @_;

    $self->verify;
    return $self->find('*transaction-lines',
        widget_args => [
            transaction_type =>
                ($self->_counterparty eq 'customer') ? 'AR' : 'AP' ]);
}

sub _extract_total {
    my ($self, $type) = @_;
    my $total_elm = $self->find("#amount-total", scheme => 'css');

    my $rv = {
        amount => $total_elm->get_text,
    };

    return $rv;
}

sub total {
    my $self = shift;

    return $self->_extract_total;
}

__PACKAGE__->meta->make_immutable;

1;
