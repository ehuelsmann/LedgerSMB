=pod

=head1 NAME

LedgerSMB:Scripts::login - web entry points for session creation/termination

=head1 SYNOPSIS

This script contains the request handlers for logging in and out of LedgerSMB.

=head1 METHODS

=over

=cut


package LedgerSMB::Scripts::login;

use LedgerSMB::Locale;
use LedgerSMB;
use LedgerSMB::User;
use LedgerSMB::Auth;
use LedgerSMB::Scripts::menu;
use LedgerSMB::Sysconfig;
use Try::Tiny;

use strict;
use warnings;
use Carp;

our $VERSION = 1.0;

=item no_db_actions

Returns an array of actions which should not receive
a request object /not/ connected to the database.

=cut

sub no_db_actions {
    return qw(logout authenticate __default logout_js);
}

=item __default (no action specified, do this)

Displays the login screen.

=cut

use Data::Printer;
sub __default {
    my ($request, $env) = @_;

    if ($request->{cookie} && $request->{cookie} ne 'Login') {
        if (! $request->_db_init()) {
            LedgerSMB::Auth::credential_prompt;
        }
        if (! $request->verify_session($env)) {
            $request->_get_password("Session expired");
        }
        $request->initialize_with_db($env);
        my $response = LedgerSMB::Scripts::menu::root_doc($request, $env);
        $response->cookies->{$request->{_new_session_cookie_value}} = {
          value => $request->{_new_session_cookie_value},
        } if $request->{_new_session_cookie_value};
        return $response->finalize;
    }

    $request->{stylesheet} = "ledgersmb.css";
    $request->{titlebar} = "LedgerSMB $request->{VERSION}";
    my $template = LedgerSMB::Template->new(
        user =>$request->{_user},
        locale => $request->{_locale},
        path => 'UI',
        template => 'login',
        format => 'HTML'
    );
    my $response = $template->render_to_psgi($request);
    $response->cookies->{$LedgerSMB::Sysconfig::cookie_name} = {
      value => 'Login',
      path => $ENV{SCRIPT_NAME} =~ s|[^/]*$||,
      secure => $ENV{SERVER_PORT} == 443 ? ' Secure;' : ''
    };
    return $response->finalize;
}

=item authenticate

This routine checks for the authentication information and if successful
sends either a 302 redirect or a 200 successful response.

If unsuccessful sends a 401 if the username/password is bad, or a 454 error
if the database does not exist.

=cut

sub authenticate {
    my ($request, $env) = @_;
    if (!$request->{dbh}){
        if (!$request->{company}){
             $request->{company} = $LedgerSMB::Sysconfig::default_db;
        }
        if (! $request->_db_init) {
            LedgerSMB::Auth::credential_prompt;
        }
    }
    if ($request->{dbh} and !$request->{log_out}){

        LedgerSMB::Session::check($request->{cookie}, $request, $env)
             unless $request->{dbonly};
        return [
          200,
          [ 'Content-Type', 'text/plain'],
          [ 'Success\n\n', 'Success\n' ]
        ];
    }
    else {
        if (($request->{_auth_error} ) && ($request->{_auth_error} =~/$LedgerSMB::Sysconfig::no_db_str/i)){
            return [
              404,
              [ 'Content-Type', 'text/plain'],
              [ 'Database Does Not Exist\n\n', 'No message here' ]
            ];
        } else {
            return [
              401,
              [ 'Content-Type', 'text/plain'],
              [ 'Unauthorized\n\n', 'Please enter your credentials.\n' ]
            ];
        }
        $request->finalize_request();
    }
}

=item login

Logs in the user and displays the root document.

=cut

sub login {
    my ($request,$env) = @_;
warn "Login++";
    if (!$request->{_user}){
        __default($request,$env);
    }
    require LedgerSMB::Scripts::menu;
    LedgerSMB::Scripts::menu::root_doc($request,$env);
warn "Login--";
}

=item logout

Logs the user out.  Handling of HTTP browser credentials is browser-specific.

Firefox, Opera, and Internet Explorer are all supported.  Not sure about Chrome

=cut

sub logout {
    my ($request,$env) = @_;

    try { # failure only means we clear out the session later
        $request->_db_init;
        LedgerSMB::Session::destroy($request,$env);
        #TODO use session state
    };
    my $template = LedgerSMB::Template->new(
        user =>$request->{_user},
        locale => $request->{_locale},
        path => 'UI',
        template => 'logout',
        format => 'HTML'
    );
    $template->render_to_psgi($request);
}

=item logout_js

This is a stup for a js logout feature.  It allows javascript to log out by
requiring only bogus credentials (logout:logout).

=cut

sub logout_js {
    my $request = shift @_;
    my $creds = LedgerSMB::Auth::get_credentials();
    LedgerSMB::Auth::credential_prompt
        unless ($creds->{password} eq 'logout')
               and ($creds->{login} eq 'logout');
    logout($request);
}


###TODO-LOCALIZE-DOLLAR-AT
eval { do "scripts/custom/login.pl"};

=back

=head1 COPYRIGHT

Copyright (C) 2009 LedgerSMB Core Team.  This file is licensed under the GNU
General Public License version 2, or at your option any later version.  Please
see the included License.txt for details.

=cut


1;
