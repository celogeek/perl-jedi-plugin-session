package Jedi::Plugin::Session::Role;

# ABSTRACT: imported method for Jedi::Plugin::Session

use strict;
use warnings;
# VERSION
use CHI;
use Digest::SHA1 qw/sha1_base64/;
use CGI::Cookie;

my @_BASE64 = (0..9, 'a'..'z', 'A'..'Z', '_', '-');

sub _get_random_base64 {
    my ($count) = @_;
    return join('', map {@_BASE64[int(rand(64))]} 1..$count);
}

use Moo::Role;

has '_jedi_session' => (is => 'lazy');
sub _build_jedi_session {
    my ($self) = @_;
    my $class = ref $self;
    my $expires_in = $self->jedi_config->{$class}{session_expiration} // '3 hours';
    return CHI->new(driver => 'Memory', expires_in => $expires_in);
}

before jedi_app => sub {
    my ($app) = @_;
    $app->get(qr{.*}, $app->can('jedi_session_setup'));
    $app->post(qr{.*}, $app->can('jedi_session_setup'));
    return;
};

sub jedi_session_setup {
    my ($self, $request, $response) = @_;
    
    # get UUID from session
    my ($uuid) = @{$request->cookies->{jedi_session} // []};

    if (!defined $uuid) {
        $uuid = _get_random_base64(12);

        # session save UUID
        my $cookie = CGI::Cookie->new(-name => 'jedi_session', -value => $uuid, -expires => '+3M');
        $response->push_header('Set-Cookie', $cookie);
    }

    $request->{'Jedi::Plugin::Session::UUID'} = sha1_base64(join('_', grep { defined } ($uuid, $request->remote_address, $request->env->{HTTP_USER_AGENT})));

    return 1;
}

sub jedi_session_get {
    my ($self, $key) = @_;

}

sub jedi_session_set {
}

1;