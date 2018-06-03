
package Dancer2::Plugin::Auth::Extensible::Provider::DBConnection;

=head1 NAME

Dancer2::Plugin::Auth::Extensible::Provider::DBConnection - Dancer2 auth using Pg roles

=head1 DESCRIPTION

This plugin for Dancer2's C<Dancer2::Plugin::Auth::Extensible> module
authenticates web application users using a DBI connection with a
database server specified in the configuration and a database name
specified in the request or the default one specified in the configuration.

=cut

use Carp qw/croak/;
use DBI;
use Try::Tiny;

use Moo;
with 'Dancer2::Plugin::Auth::Extensible::Role::Provider';
use namespace::autoclean;

our $VERSION = '0.001';

=head1 ATTRIBUTES

=head2 auth_database

Taken from the web application configuration file, specifies the default
database to authenticate against.

=cut

has auth_database => ( is => 'ro' );

=head1 METHODS

=head2 authenticate_user($username, $password)

Implements C<Dancer2::Plugin::Auth::Extensible::Role::Provider>'s
C<authenticate_user> protocol.

In case a parameter C<__auth__extensible_database> is present
in the request, that database is used to authenticate against. If not,
authentication happens against the configured C<auth_database>.

=cut


sub authenticate_user {
   my ($self, $username, $password) = @_;

   croak 'username and password must be defined'
     unless defined $username and defined $password;

   my $dbname =
       $self->auth_database
       // $self->plugin->app->request
          ->body_parameters->get('__auth_extensible_database');
   croak q{session doesn't contain database name for auth}
     unless defined $dbname;

   my $dbh;
   try {
     $dbh = DBI->connect('dbi:Pg:host=postgres;dbname=' . $dbname,
                         $username, $password);
   };

   if (defined $dbh) {
      my $session = $self->plugin->app->session;
      $session->write('__auth_extensible_database', $dbname);
      $session->write('__auth_extensible_pass', $password);

      return 1;
   }

   return 0;
}

=head1 LICENSE AND COPYRIGHT

This module is copyright (C) 2018, the LedgerSMB Core Team and subject to
the GNU General Public License (GPL) version 2, or at your option, any later
version.  See the COPYRIGHT and LICENSE files for more information.

=cut

1;
