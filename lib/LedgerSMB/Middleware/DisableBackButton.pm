
package LedgerSMB::Middleware::DisableBackButton;

=head1 NAME

LedgerSMB::Middleware::DisableBackButton - Disables back button

=head1 SYNOPSIS

 builder {
   enable "+LedgerSMB::Middleware::DisableBackButton";
   $app;
 }

=head1 DESCRIPTION

LedgerSMB::Middleware::DisableBackButton sets extremely strict cache
control policies, effectively rendering the back button useless as a
means of leaking information (no way to "back button back into the
ledger" after logging out).

The policy kicks in when so configured in the company database.

=cut

use strict;
use warnings;
use parent qw ( Plack::Middleware );

use Plack::Util;

use LedgerSMB::Setting;


=head1 METHODS

=head2 $self->call($env)

Implements C<Plack::Middleware->call()>.

=cut

sub call {
    my $self = shift;
    my ($env) = @_;
    my $res = $self->app->($env);

    return $self->response_cb($res, sub {
        return unless $env->{'lsmb.db'};

        my $res = shift;
        my ($status, $headers, $body) = @$res;
        local $@ = undef;
        # LedgerSMB::old_code::dispatch() can cause the connection to be
        # closed: it fork()s but doesn't close/reopen the connection around
        # the fork() call. Upon exit() of the forked child, the database
        # handle will be closed, affecting the parent's handle.
        my $disable = eval {
            LedgerSMB::Setting->new(dbh => $env->{'lsmb.db'})->get('disable_back');
        };
        if (not $disable or $@) {
            # err on the safe side: disable the back button when we had an error
            # retrieving whether we want it or not...
            if ($@) {
                $env->{'psgix.logger'}->({
                    level => 'error',
                    msg => 'Disabling back button: error retrieving configuration',
                    });
            }
            push @$headers, (
                'Cache-Control' => join(', ',
                                        qw| no-store  no-cache  must-revalidate
                                        post-check=0 pre-check=0 false|),
                'Pragma' => 'no-cache'
                );
        }
    });
}

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2017 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut


1;
