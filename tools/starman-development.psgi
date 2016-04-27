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
            qw(Parameters Environment Response Timer Memory Session Log4perl),
               [ 'Ajax', log_limit => 100 ],
               [ 'DBITrace', level => 2 ],
               [ 'Profiler::NYTProf', exclude => [qw(.*\.css .*\.png .*\.ico .*\.js .*\.gif)], minimal => 1 ],
#            qw/Dancer::Settings Dancer::Logger Parameters Dancer::Version/
    ] if $ENV{PLACK_ENV} =~ "development";

#    # Enable Stacktrace when being accessed from the local network
#    enable_if { $_[0]->{REMOTE_ADDR} =~ /^192\.168\.30\.*/ } 'StackTrace';

#    enable 'Log4perl', category => 'plack', conf => \$log4perl_conf;

#  enable "iPhone",
#      tidy => 1,
#      manifest => 'app.manifest',
#      viewport => 'initial-scale = 1, maximum-scale = 1.5, width = device-width',
#      statusbar => 'black-translucent',
#      startup_image => 'loading.png',
#      icon => 'icon.png';

    enable "LighttpdScriptNameFix";
    enable "ConditionalGET";
    enable "Plack::Middleware::ETag", file_etag => "inode", cache_control => [ 'must-revalidate', 'max-age=3600' ];
  
    enable 'StackTrace', unsafe_ref_capture => 1;
    enable 'InteractiveDebugger';
#   enable "HTTPExceptions", rethrow => 1;

#    # Transcode Jpeg on the fly for mobile clients
#    enable 'MobileDetector';
#    enable_if { $_[0]->{'plack.mobile_detected'} }
#        'TranscodeJpeg', max_size => 30_000;

    mount '/stop.pl' => sub { exit; }
        if $ENV{COVERAGE};

    mount '/' => $app;
};

