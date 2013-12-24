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

sub Jedi::Request::session_get { my ($self, @params) = @_; return $self->{'Jedi::Plugin::Session::get'}->($self, @params) }
sub Jedi::Request::session_set { my ($self, @params) = @_; return $self->{'Jedi::Plugin::Session::set'}->($self, @params) }

use Moo::Role;

has '_jedi_session' => (is => 'lazy');
sub _build__jedi_session {
    my ($self) = @_;
    my $class = ref $self;
    my $expires_in = $self->jedi_config->{$class}{session_expiration} // '3 hours';
    return CHI->new(driver => 'Memory', datastore => {}, expires_in => $expires_in);
}

before jedi_app => sub {
    my ($app) = @_;
    $app->get(qr{.*}x, $app->can('jedi_session_setup'));
    $app->post(qr{.*}x, $app->can('jedi_session_setup'));
    return;
};

sub jedi_session_setup {
    my ($self, $request, $response) = @_;
    
    # get UUID from session
    my ($uuid) = @{$request->cookies->{jedi_session} // []};

    if (!defined $uuid) {
        $uuid = _get_random_base64(12);

        # session save UUID
        my $cookie = CGI::Cookie->new(-name => 'jedi_session', -value => $uuid, -expires => '+24M');
        $response->push_header('Set-Cookie', $cookie);
    }

    my $full_uuid = sha1_base64(join('_', grep { defined } ($uuid, $request->remote_address, $request->env->{HTTP_USER_AGENT})));
    $request->{'Jedi::Plugin::Session::UUID'} = $full_uuid;
    $request->{'Jedi::Plugin::Session::get'} = sub {$self->_jedi_session->get($full_uuid)};
    $request->{'Jedi::Plugin::Session::set'} = sub { my (undef, $value) = @_; $self->_jedi_session->set($full_uuid, $value)};

    return 1;
}

1;
