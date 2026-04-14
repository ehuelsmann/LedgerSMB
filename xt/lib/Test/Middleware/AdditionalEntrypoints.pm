
package Test::Middleware::AdditionalEntrypoints;

use v5.38;
use warnings;
use parent qw ( Plack::Middleware );
use experimental qw( signatures );

use Data::Dumper;
use Data::UUID;
use HTTP::Status qw( HTTP_OK );
use JSON::PP;



my $json = JSON::PP->new->utf8;

sub call($self, $env) {

    if ($env->{PATH_INFO} eq '/dev/kill') {
        exit 0;
    }

    if ($env->{PATH_INFO} eq '/dev/status') {
        return [
            HTTP_OK,
            [ 'Content-Type' => 'application/json; charset=UTF-8' ],
            [ $json->encode({ schema => $env->{wire}->get('db')->schema }) ] ];
    }

    if ($env->{SCRIPT_NAME} eq '/dev/coverage-upload') {

    }

    return $self->app->($env);
}

1;
