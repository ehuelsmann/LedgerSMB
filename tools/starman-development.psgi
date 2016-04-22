#!/usr/bin/plackup 

package LedgerSMB::FCGI;

use CGI::Emulate::PSGI;
use LedgerSMB::PSGI;
use Plack::Builder;
use Plack::Middleware::Static;


my $app = LedgerSMB::PSGI::app();

builder {
    enable "Plack::Middleware::Static",
       path => qr{(^/?(images|doc|UI|css)/|favicon\.ico)}, root => '.';

    enable 'Debug',  panels => [
            qw(Environment Response Timer Memory Session),
            [ 'DBITrace', level => 2 ],
            [ 'Profiler::NYTProf', exclude => [qw(.*\.css .*\.png .*\.ico .*\.js .*\.gif)], minimal => 1 ],
    ] if $ENV{PLACK_ENV} =~ "development";

#    # Enable Stacktrace when being accessed from the local network
#    enable_if { $_[0]->{REMOTE_ADDR} =~ /^192\.168\.30\.*/ } 'StackTrace';

#    enable 'StackTrace', unsafe_ref_capture => 1;
    enable 'InteractiveDebugger'; # if $ENV{PLACK_ENV} =~ "development";
    enable "HTTPExceptions", rethrow => 1; # if $ENV{PLACK_ENV} =~ "development";

    # Transcode Jpeg on the fly for mobile clients
#    enable 'MobileDetector';
#    enable_if { $_[0]->{'plack.mobile_detected'} }
#        'TranscodeJpeg', max_size => 30_000;

    mount '/stop.pl' => sub { exit; }
        if $ENV{COVERAGE};

    mount '/' => $app;
};

