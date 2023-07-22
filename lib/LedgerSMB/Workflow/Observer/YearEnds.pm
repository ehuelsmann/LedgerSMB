package LedgerSMB::Workflow::Observer::YearEnds;

=head1 NAME

LedgerSMB::Workflow::Observer::YearEnds - Controller for combined year end state

=head1 SYNOPSIS

  # observer configuration
  <workflow>
     <type>...</type>

     <observer class="LedgerSMB::Workflow::Observer::YearEnds">
  </workflow>


=head1 DESCRIPTION

This module implements an observer which 


=head1 CLASS METHODS

=cut


use strict;
use warnings;
use parent qw( Class::Accessor );

use Log::Any qw($log);

my @PROPS = qw( history_text );
__PACKAGE__->mk_accessors(@PROPS);

=head2 update($wf, $event, $new_state [, $old_state, $action ] )

Implements the C<Workflow>'s C<Observer> protocol.

=cut

sub _change_previous_yearend {
    my ($wf, $action) = @_;
    my $id = $wf->_factory->get_persister( 'Year-End' )
        ->previous_yearend_id( $wf );

    return unless defined $id;
    my $prev = $wf->_factory->fetch_workflow( 'Year-End', $id );
    $prev->execute_action( $action );
}


sub update {
    my ($class, $wf, $event, $new_state, $old_state, $action) = @_;
    return unless $event eq 'execute';
    return if $new_state eq $old_state;

    if ($new_state eq 'REVERSED') {
        # unblock previous year-end
        _change_previous_yearend( $wf, 'unblock' );
    }
    elsif ($new_state eq 'POSTED') {
        # block previous year-end
        _change_previous_yearend( $wf, 'block' );
    }
    # else do nothing
}


1;

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2023 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

