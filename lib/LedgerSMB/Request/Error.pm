=head1 NAME

LedgerSMB::Request::Error - HTTP Request error handling for LedgerSMB

=head1 SYNOPSIS

 die LedgerSMB::Request::Error->new(msg => 'something went wrong');

or

 die LedgerSMB::Request::Error->new(status => 422, msg => "you forgot to fill in country code");

=head1 PROPERTIES

=cut

package LedgerSMB::Request::Error;
use LedgerSMB::App_State;
use Moose;

=head2 status (default 500)

HTTP status to send

=cut

has status => (is => 'ro', isa => 'Int', default => '500');

=head2 msg

String to send as error message

=cut

has msg => (is => 'ro', isa => 'Object', required => 1);

=head1 METHODS

=head2 http_response($additional_html,$trace)

Generates full http response based on error.  Does NOT exit

=cut

sub http_response {
    my ($self, $additional_html, $trace) = @_;
    my $status = $self->status;
	warn $status;
    my $msg = $self->msg;
    $msg ||= '';
    $msg =~ s#\n#<br \/>\n#g;
    $additional_html ||= '';
    $additional_html =~ s#\n#<br />\n#g;
    my $user = LedgerSMB::App_State::User;
    my $stylesheet = $user->{stylesheet} || '';

    if ( $trace ) {
        use lib qw(lib/LedgerSMB);
		require AsHTML;
        my $html = $trace->as_html(); # like carp
        $msg = "Error: " . $msg; # . "<br/>Trace";
        $html =~ s/Error trace/$msg/;
        return $html;
#		# $html should contains a full html page. Bodies should conflict.
#        return qq|Status: $status ISE\nContent-Type: text/html; charset=utf-8\n\n|
#               . "<head><link rel='stylesheet' href='css/$stylesheet' type='text/css'></head>"
#               . qq|<body><h2 class="error">Error!</h2> <p><b>$msg</b></p>
#				$additional_html
#             </body>$html|;
    } else {
        return qq|Status: $status ISE\nContent-Type: text/html; charset=utf-8\n\n|
               . "<head><link rel='stylesheet' href='css/$stylesheet' type='text/css'></head>"
               . qq|<body><h2 class="error">Error!</h2> <p><b>$msg</b></p>
             $additional_html
             </body>|;
    }
}

=head2 throw

Dies with the status as return code after displaying error.

=cut

sub throw {
    my ($self) = @_;
    warn $self->msg;
    exit $self->status;
}

use Moose::Util ();

use if ( not our $__mx_is_compiled ), 'Moose::Meta::Class';
use if ( not our $__mx_is_compiled ), metaclass => 'Moose::Meta::Class';

sub new {
#    use Devel::StackTrace::WithLexicals;
#    use lib qw(lib/LedgerSMB);
#    require AsHTML;
#    print Devel::StackTrace::WithLexicals->new()->as_html();

    my $class = shift;
    my $real_class = Scalar::Util::blessed($class) || $class;

    my $params = $real_class->BUILDARGS(@_);

    return Class::MOP::Class->initialize($real_class)->new_object($params);
}

before BUILDARGS => sub {
    warn "BUILDARGS++";
};

sub BUILDARGS {
    my $class = shift;
    if ( scalar @_ == 1 ) {
        unless ( defined $_[0] && ref $_[0] eq 'HASH' ) {
            Moose::Util::throw_exception( "SingleParamsToNewMustBeHashRef" );
        }
        return { %{ $_[0] } };
    }
    elsif ( @_ % 2 ) {
        Carp::carp(
            "The new() method for $class expects a hash reference or a key/value list."
                . " You passed an odd number of arguments" );
        return { @_, undef };
    }
    else {
        return { @_ };
    }
}

after BUILDARGS => sub {
    warn "BUILDARGS--";
};

before BUILD => sub {
    warn "BUILD++";
};

sub BUILD {
    my $self = shift;

    warn "Made a new Error: $self->status";
}

after BUILD => sub {
    warn "BUILD--";
};

sub BUILDALL {
    # NOTE: we ask Perl if we even
    # need to do this first, to avoid
    # extra meta level calls
    return unless $_[0]->can('BUILD');
    my ($self, $params) = @_;
    foreach my $method (reverse Class::MOP::class_of($self)->find_all_methods_by_name('BUILD')) {
        $method->{code}->execute($self, $params);
    }
}

sub DEMOLISHALL {
    my $self = shift;
    my ($in_global_destruction) = @_;

    # NOTE: we ask Perl if we even
    # need to do this first, to avoid
    # extra meta level calls
    return unless $self->can('DEMOLISH');

    my @isa;
    if ( my $meta = Class::MOP::class_of($self ) ) {
        @isa = $meta->linearized_isa;
    } else {
        # We cannot count on being able to retrieve a previously made
        # metaclass, _or_ being able to make a new one during global
        # destruction. However, we should still be able to use mro at
        # that time (at least tests suggest so ;)
        my $class_name = ref $self;
        @isa = @{ mro::get_linear_isa($class_name) }
    }

    foreach my $class (@isa) {
        no strict 'refs';
        my $demolish = *{"${class}::DEMOLISH"}{CODE};
        $self->$demolish($in_global_destruction)
            if defined $demolish;
    }
}

sub DESTROY {
    my $self = shift;

    local $?;

    # < doy> if the destructor is being called because an exception is thrown, then $@ will be set
    # < doy> but if DEMOLISH does an eval which succeeds, that will clear $@
    # < doy> which is broken
    # < doy> try::tiny implicitly localizes $@ in the try block, which fixes that
    Try::Tiny::try {
        $self->DEMOLISHALL(Devel::GlobalDestruction::in_global_destruction);
    }
    Try::Tiny::catch {
        die $_;
    };

    return;
}

# support for UNIVERSAL::DOES ...
BEGIN {
    my $does = UNIVERSAL->can("DOES") ? "SUPER::DOES" : "isa";
    eval 'sub DOES {
        my ( $self, $class_or_role_name ) = @_;
        return $self->'.$does.'($class_or_role_name)
            || $self->does($class_or_role_name);
    }';
}

# new does() methods will be created
# as appropriate see Moose::Meta::Role
sub does {
    my ($self, $role_name) = @_;
    my $class = Scalar::Util::blessed($self) || $self;
    my $meta = Class::MOP::Class->initialize($class);
    (defined $role_name)
        || Moose::Util::throw_exception( DoesRequiresRoleName => class_name => $meta->name );
    return 1 if $meta->can('does_role') && $meta->does_role($role_name);
    return 0;
}

sub dump {
    my $self = shift;
    require Data::Dumper;
    local $Data::Dumper::Maxdepth = shift if @_;
    Data::Dumper::Dumper $self;
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
