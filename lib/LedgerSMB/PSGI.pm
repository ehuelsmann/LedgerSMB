package LedgerSMB::PSGI;

=head1 NAME

LedgerSMB::PSGI - PSGI application routines for LedgerSMB

=head1 SYNOPSIS

 use LedgerSMB::PSGI;
 my $app = LedgerSMB::PSGI->get_app();

=cut

use strict;
use warnings;

# Preloads
use LedgerSMB;
use LedgerSMB::Form;
use LedgerSMB::Sysconfig;
use LedgerSMB::Template;
use LedgerSMB::Template::HTML;
use LedgerSMB::Locale;
use LedgerSMB::File;
use LedgerSMB::Scripts::login;
use LedgerSMB::PGObject;
use Try::Tiny;

use CGI::Emulate::PSGI;
use Module::Runtime qw/ use_module /;
# use Carp::Always;

local $@; # localizes just for initial load.
eval { require LedgerSMB::Template::LaTeX; };
$ENV{GATEWAY_INTERFACE}="cgi/1.1";

=head1 FUNCTIONS

=over

=item rest_app

Returns a 'PSGI app' which handles GET/POST requests for the RESTful services

=cut

sub rest_app {
   return CGI::Emulate::PSGI->handler(
     sub {
       do 'bin/rest-handler.pl';
    });
}

=item old_app

Returns a 'PSGI app' which handles requests for the 'old-code' scripts in bin/

=cut

sub old_app {
    return CGI::Emulate::PSGI->handler(
        sub {
            my $uri = $ENV{REQUEST_URI};
            $uri =~ s/\?.*//;
            $ENV{SCRIPT_NAME} = $uri;

            _run_old();
        });
}


=item new_app

Returns a 'PSGI app' which handles requests for the 'new code' entry points
in LedgerSMB::Scripts::*

=cut


sub new_app {
   return CGI::Emulate::PSGI->handler(
        sub {
           my $uri = $ENV{REQUEST_URI};
           local $ENV{SCRIPT_NAME} = $uri;
           my $script = $uri;
           $ENV{SCRIPT_NAME} =~ s/\?.*//;
           $script =~ s/.*[\\\/]([^\\\/\?=]+\.pl).*/$1/;

           _run_new($script);
       });
}


=item psgi_app

Implements a PSGI application for the purpose of calling the entry-points
in LedgerSMB::Scripts::*.

=cut

use Data::Printer;
sub _psgi_app {
  my $env = shift;
  warn p($env);
  # Taken from CGI::Emulate::PSGI, to ease migration.
  no warnings;
  my $environment = {
      GATEWAY_INTERFACE => 'CGI/1.1',
      HTTPS => ( ( $env->{'psgi.url_scheme'} eq 'https' ) ? 'ON' : 'OFF' ),
      SERVER_SOFTWARE => "CGI-Emulate-PSGI",
      REMOTE_ADDR     => '127.0.0.1',
      REMOTE_HOST     => 'localhost',
      REMOTE_PORT     => int( rand(64000) + 1000 ),    # not in RFC 3875
      ( map { $_ => $env->{$_} }
        grep { !/^psgix?\./ && $_ ne "HTTP_PROXY" } keys %$env )
  };
  # End of CGI::Emulate::PSGI

  local %ENV = ( %ENV, %$environment );
  my $uri = $env->{REQUEST_URI};
  local $ENV{SCRIPT_NAME} = $uri;

  my $request = LedgerSMB->new();
  $request->{action} ||= '__default';
  my $locale = $request->{_locale};
  $LedgerSMB::App_State::Locale = $locale;

  # $request is really a global which should be stashed in the session.
  $env->{request} = $request;
  warn p($env);
  return %ENV;
}

sub psgi_app {
    my $env = shift;
    local %ENV = _psgi_app($env);
    warn p($env);

    $ENV{SCRIPT_NAME} =~ m/([^\/\\]*)\.pl(\?.*)?$/;
    my $script = "LedgerSMB::Scripts::$1";
    my $request = $env->{request};
    $request->{_script_handle} = $script;

    return [ 500,
             [ 'Content-Type' => 'text/html' ],
             [ '<html><body><h1>No workflow script specified!</h1></body></html>' ]
        ]
                 unless $script;

    return [ 500,
             [ 'Content-Type' => 'text/html; charset=utf-8' ],
             [ "<html><body><h1>Unable to open script $script : $! : $@</h1></body></html>" ]
        ]
        unless use_module($script);

    my $action = $script->can($request->{action});
    return [ 500,
             [ 'Content-Type' => 'text/html; charset=utf-8' ],
             [ "<html><body><h1>Action Not Defined: $request->{action}</h1></body></html>" ]
        ]
        unless $action;

    my ($status, $headers, $body);
    try {
        if (! $script->can('no_db')) {
            my $no_db = $script->can('no_db_actions');

            if (!$no_db
                || ( $no_db && ! grep { $_ eq $request->{action} } $no_db->())) {
                $request->_db_init();
                $request->initialize_with_db();
            }
        }

        $LedgerSMB::App_State::DBH = $request->{dbh};
        ($status, $headers, $body) = @{&$action($request)};

        $request->{dbh}->commit if defined $request->{dbh};
        LedgerSMB::App_State->cleanup();
    }
    catch {
        my $error = $_;
        eval {
            $LedgerSMB::App_State::DBH->rollback
                if ($LedgerSMB::App_State::DBH && $_ eq 'Died');
        };
        eval {
            LedgerSMB::App_State->cleanup();
        };
        return [ 500,
                 [ 'Content-Type' => 'text/html; charset=utf-8' ],
                 [ qq|<html>
<body><h2 class="error">Error!</h2> <p><b>$_</b></p>
<p>dbversion: $request->{dbversion}, company: $request->{company}</p>
</body>
</html>
| ]
            ]
            unless $error =~ /^Died at/;
    };

    push @$headers, ( 'Set-Cookie' =>
                      $request->{'request.download-cookie'} . '=downloaded' )
        if $request->{'request.download-cookie'};
    return [ $status, $headers, $body ];
}

sub _run_old {
    if (my $cpid = fork()){
       wait;
    } else {
       do 'bin/old-handler.pl';
       exit;
    }
}

sub _run_new {
    my ($script) = @_;
    if (-f 'bin/lsmb-request.pl'){
        try {
            do 'bin/lsmb-request.pl';
        }
        catch {
            # simple 'die' statements are request terminations
            # so we don't want to cause a 500 ISE to be returned
            die $_
                unless $_ =~ /^Died at/;
        }
    } else {
        die 'something is wrong, cannot find lsmb-request.pl';
    }
}

=back

=cut

1;
