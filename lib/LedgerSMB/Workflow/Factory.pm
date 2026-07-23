
use v5.38;

package LedgerSMB::Workflow::Factory;

use parent 'Workflow::Factory';

=head1 NAME

LedgerSMB::Workflow::Factory - LedgerSMB factory for the instantiation of workflows

=head1 SYNOPSYS

  use LedgerSMB::Workflow::Factory;

  my $wire      = Beam::Wire->new( file => 'ledgersmb.yaml' );
  my $singleton = LedgerSMB::Workflow::Factory->instance( $wire );

=head1 DESCRIPTION



=head1 PROPERTIES

=head2 wire

Contains the L<Beam::Wire> dependency injection configuration instance, to
be passed onto LedgerSMB::Workflow instances.

=cut

my @FIELDS = qw( wire );
__PACKAGE__->mk_accessors( @FIELDS );

=head1 CLASS METHODS

=head2 instance

  $singleton = LedgerSMB::Workflow::Factory->instance( $wire );

Instantiates a singleton workflow factory carrying the C<$wire> application
configuration instance.

=cut

sub instance($class, $wire) {
    my $instance = $class->SUPER::instance();
    $instance->wire( $wire );

    return $instance;
}

=head1 METHODS

=head2 Public methods

=head3 init

  $factory->init();

=cut

sub init($self, @args) {
    $self->SUPER::init(@args);

    # compensate for the fact that the class isn't in the configuration,
    # but "patched in" below
    $self->_load_class( 'LedgerSMB::Workflow' );
}

=head3 create_workflow

  my $wf = $factory->create_workflow( $wf_type, [$context], [$wf_class] );

Returns a new workflow instance of class C<LedgerSMB::Workflow> from the
indicated C<$wf_type> (indicated by the C<type> in the workflow configuration).

See L<Workflow::Factory/create_workflow> for more.

=cut

sub create_workflow( $self, $wf_type, $context = undef, $wf_class = undef) {
    my $wf = $self->SUPER::create_workflow(
        $wf_type,
        $context,
        $wf_class );

    $wf->{wire} = $self->wire;
    return $wf;
}

=head3 fetch_workflow

  my $wf = $factory->fetch_workflow( $wf_type, $wf_id, [$context], [$wf_class] );

Returns an existing workflow instance created from stored state.

See L<Workflow::Factory/fetch_workflow> for more.

=cut

sub fetch_workflow( $self, $wf_type, $wf_id, $context = undef, $wf_class = undef ) {
    my $wf = $self->SUPER::fetch_workflow(
        $wf_type,
        $wf_id,
        $context,
        $wf_class );

    $wf->{wire} = $self->wire;
    return $wf;
}

=head2 Private methods

=head3 _get_workflow_config

  $wf_config = $self->_get_workflow_config( $wf_type );

Patches the workflow configuration to create L<LedgerSMB::Workflow> class
workflow instances instead of the regular L<Workflow> default.

=cut

sub _get_workflow_config( $self, $wf_type ) {
    my $wf_config = $self->SUPER::_get_workflow_config( $wf_type );
    $wf_config->{class} //= 'LedgerSMB::Workflow';

    return $wf_config;
}

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2026 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

