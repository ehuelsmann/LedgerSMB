package LedgerSMB::Company::Configuration::Parts;

=head1 NAME

LedgerSMB::Company::Configuration::Parts - Collection of goods and services

=head1 SYNOPSIS

   use LedgerSMB::Database;
   use LedgerSMB::Company;

   my $dbh = LedgerSMB::Database->new( connect_data => { ... })
       ->connect;
   my $c   = LedgerSMB::Company->new(dbh => $dbh)->configuration->coa_nodes;

   # look up a heading or account
   my $node   = $c->get(by => (partnumber => 'P-12'));

   # create a new node (account)
   my $new    = $c->create(type        => 'account',
                           accno       => '1501',
                           description => 'Account 1501',
                           heading_id  => $node->id);

=head1 DESCRIPTION

Collection of goods and services providing access to existing nodes as well as
providing an API to create (instantiate) new ones.

=cut


use warnings;
use strict;

use Log::Any qw($log);
use PGObject::Type::Registry;

use Moose;
use namespace::autoclean;
with 'LedgerSMB::Company::Configuration::Collection';

# required methods from Collection:

sub _resultset {
    return q{
    SELECT id, partnumber, description, unit, listprice, sellprice, lastcost,
           priceupdate, weight, notes, makemodel, assembly, alternate, rop,
           inventory_accno_id, income_accno_id, expense_accno_id,
           returns_accno_id,
           bin, obsolete, bom, partsgroup_id
    FROM parts
};
    # Intentionally leaving out:
    #  avgcost
    #  microfiche
    #  drawing
    #  image
    #  onhand

    # onhand and avgcost should be dynamically calculated and are rather
    # costly to calculate beforehand.
    #
    # microfiche, drawing and image, I'd rather move to attachment types
    # or note types of some sort; meaning I'd rather not support them
    # through fixed fields on the object
}

sub _class {
    # unused, because we override 'instantiate'
    return '';
}

sub _instantiate {
    my ($self, $row, @args) = @_;
    if ($row->{assembly}) {
        return LedgerSMB::Company::Configuration::Assembly->new(@args);
    }
    elsif ($row->{inventory_accno_id}
           and $row->{income_accno_id}
           and $row->{expense_accno_id}) {
        return LedgerSMB::Company::Configuration::Part->new(@args);
    }
    elsif ($row->{income_accno_id}
           and $row->{expense_accno_id}) {
        return LedgerSMB::Company::Configuration::Service->new(@args);
    }
    else {
        return LedgerSMB::Company::Configuration::Overhead->new(@args);
    }
}

#my %fieldmap = ( code => 'accno' );
#sub _map_field {
#    my ($self, $fieldname) = @_;
#    return $fieldmap{$fieldname} // $fieldname;
#}





#use LedgerSMB::Company::Configuration::Assembly;
use LedgerSMB::Company::Configuration::Overhead;
use LedgerSMB::Company::Configuration::Part;
use LedgerSMB::Company::Configuration::Service;

=head1 ATTRIBUTES

=cut

has _dbh => (is => 'ro', init_arg => 'dbh', reader => 'dbh', required => 1);


=head1 CONSTRUCTOR ARGUMENTS

In addition to the attributes from the previous section, the following
named arguments can (or even must) be provided to the C<new> constructor.

=head2 dbh (required)

The database access handle. This is provided upon instantiation by the
C<LedgerSMB::Company::Configuration::COANodes> collection.

=head1 METHODS

=head2 create( type => $type, @args )

Instantiates a new part of type C<type>, associated with the database
that the collection is associated with.

C<type> can be C<assembly>, C<overhead>, C<part> or C<service>.

C<@args> are passed to the constructor of the indicated type,
C<LedgerSMB::Company::Configuration::Assembly> for type C<assembly>,
C<LedgerSMB::Company::Configuration::Overhead> for type C<overhead>,
C<LedgerSMB::Company::Configuration::Part> for type C<part>,
and C<LedgerSMB::Company::Configuration::Service> for type C<service>.

=cut

my %typemap = (
    assembly => 'LedgerSMB::Company::Configuration::Assembly',
    overhead => 'LedgerSMB::Company::Configuration::Overhead',
    part     => 'LedgerSMB::Company::Configuration::Part',
    service  => 'LedgerSMB::Company::Configuration::Service',
    );

sub create {
    my $self = shift;
    my %args = @_;

    die "Unexpected part type ($args{type})"
        unless exists $typemap{$args{type}};

    return $typemap{$args{type}}->new(
        _dbh => $self->dbh,
        @_
        );
}

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2020 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut

__PACKAGE__->meta->make_immutable;

1;
