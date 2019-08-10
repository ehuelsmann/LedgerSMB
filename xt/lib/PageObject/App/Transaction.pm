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

sub _post_btn {
    my ($self) = @_;

    my $outer = $self->find('.//span[contains(@widgetid,"action-post-")]
                             | .//span[contains(@widgetid,"action-approve-")]');
    my $lbl_id = $outer->get_attribute('widgetid');
    my $label = $self->find(qq{//span[\@id="${lbl_id}_label"]});
    return $label;
}

sub _post_btn_text {
    my ($self) = @_;

    return $self->_post_btn->get_text;
}

sub post {
    my ($self) = @_;
    if ($self->_post_btn_text eq 'Save') {
        # 2-step in case separation of duties is enabled
        my $btn = $self->_post_btn;
        $btn->click;
        $self->session->page->body->maindiv->wait_for_content(replaces => $btn);
    }

    my $btn = $self->session->page->body->maindiv->content->_post_btn;
    $btn->click;
    $self->session->page->body->maindiv->wait_for_content(replaces => $btn);
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
