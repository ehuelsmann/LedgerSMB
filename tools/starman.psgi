#!/usr/bin/plackup



BEGIN {
    if ( $ENV{'LSMB_WORKINGDIR'}
         && -f "$ENV{'LSMB_WORKINGDIR'}/lib/LedgerSMB.pm" ) {
        chdir $ENV{'LSMB_WORKINGDIR'};
    }
    if ( $ENV{PLACK_ENV} && $ENV{PLACK_ENV} eq 'development' ) {
        $ENV{PLACK_SERVER}       = 'Standalone';
        $ENV{METACPAN_WEB_DEBUG} = 1;
    }
}

package LedgerSMB::FCGI;

use FindBin;
use lib $FindBin::Bin . "/../lib";
use CGI::Emulate::PSGI;
use LedgerSMB;
use LedgerSMB::Auth;
use LedgerSMB::PSGI;
use LedgerSMB::Sysconfig;
use Plack::Builder;
use Plack::App::File;
use Plack::Middleware::Log4perl;
use Plack::Middleware::PSGIAuthForm;
use Plack::Middleware::Redirect;
#use Plack::Middleware::TemplateToolkit;
# Optimization
use CHI;
use Plack::Middleware::ETag;
use Plack::Middleware::ConditionalGET;
use Plack::Builder::Conditionals;
# Development specific
use Plack::Middleware::Debug::Log4perl;

require Plack::Middleware::Pod
    if ( $ENV{PLACK_ENV} && $ENV{PLACK_ENV} eq 'development' );

my $path = $INC{"LedgerSMB.pm"};
my $version = $LedgerSMB::VERSION;
die "Library verification failed (found $version from '$path', expected 1.6)"
    unless $version =~ /^1\.6\./;

# # Lets report to the console what type of dojo we are running with
if ( $LedgerSMB::Sysconfig::dojo_built) {
    print "Starting Worker on PID $$ Using Built Dojo\n";
} else {
    print "Starting Worker on PID $$ Using Dojo Source\n";
}

my $old_app = LedgerSMB::PSGI::old_app();
my $new_app = LedgerSMB::PSGI::new_app();
my $psgi_app = \&LedgerSMB::PSGI::psgi_app;

my $chi = CHI->new( driver => 'Memory', global => 1 );

# Use your own Log4perl configuration
use Log::Log4perl;
Log::Log4perl::init(\$LedgerSMB::Sysconfig::log4perl_config);

builder {
   enable 'Cache::CHI', chi => $chi, rules => [
      qr{\.(css|js)$}     => { expires_in => '15 min' },
      qr{\.(jpg|png)$}    => { expires_in => '1 year' },
   ], scrub => [ 'Set-Cookie' ], cachequeries => 1;

    enable 'Log4perl';
    enable 'Session', store => 'File';
    enable 'PSGIAuthForm';

    enable 'Redirect', url_patterns => [
        qr/^\/?$/ => ['/login',302]
    ];

    enable match_if path(qr!.+\.(css|js|png|ico|jp(e)?g|gif)$!),
        'ConditionalGET';

    enable "Plack::Middleware::ETag",
        file_etag => [qw/inode mtime size/];

    enable 'ContentLength';

# Cool Debug Panel.
    enable 'Debug',  panels => [
# The commented parameters aren't very usefull
            qw(Parameters Environment Response Log4perl Session),   # Timer Memory ModuleVersions PerlConfig
# Profiler is very nice but VERY costly
#              [ 'Profiler::NYTProf', exclude => [qw(.*\.css .*\.png .*\.ico .*\.js .*\.gif)], minimal => 1 ],
# Dancer not yet there.
#           qw/Dancer::Settings Dancer::Logger Dancer::Version/
    ] if $ENV{PLACK_ENV} =~ "development";

    enable 'Plack::Middleware::Pod',
        path => qr{^/pod/},
        root => './',
        pod_view => 'Pod::POM::View::HTMl' # the default
    if $ENV{PLACK_ENV} =~ "development";

    # old code had: print qq|Set-Cookie: $cookie_name=Login; path=$path;$secure\n|;
    # my $path = $ENV{SCRIPT_NAME} =~ s|[^/]*$||;
    # XSRFBlock uses '/' as path
    enable 'XSRFBlock',
        parameter_name          => 'xsrf_token',
        cookie_name             => $LedgerSMB::Sysconfig::cookie_name,
        cookie_options          => { secure => $ENV{SERVER_PORT} == 443 ? 1 : 0},
        cookie_expiry_seconds   => (3 * 60 * 60),
        token_per_request       => 0,
        meta_tag                => undef,
        inject_form_input       => 1,
        header_name             => undef,
        secret                  => undef,
        blocked                 => sub {
                                    return [ $status, $headers, $body ]
                                };

#    enable 'TemplateToolkit',
#        INCLUDE_PATH => 'UI',     # required
#        pass_through => 1;        # delegate missing templates to $app

    mount '/rest/' => LedgerSMB::PSGI::rest_app();

    # not using @LedgerSMB::Sysconfig::scripts: it has not only entry-points
    mount "/$_" => $old_app
        for ('aa.pl', 'am.pl', 'ap.pl',
             'ar.pl', 'gl.pl', 'ic.pl', 'ir.pl',
             'is.pl', 'oe.pl', 'pe.pl');

    mount "/account.pl" => $psgi_app;

    mount "/$_" => $new_app
        for  (@LedgerSMB::Sysconfig::newscripts);

    mount '/stop.pl' => sub { exit; }
        if $ENV{COVERAGE};

    mount '/' => Plack::App::File->new( root => 'UI' )->to_app;
};

# -*- perl-mode -*-
