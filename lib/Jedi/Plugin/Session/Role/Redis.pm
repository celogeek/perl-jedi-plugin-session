package Jedi::Plugin::Session::Role::Redis;

# ABSTRACT: Memory Backend

use strict;
use warnings;
# VERSION

use Jedi::Plugin::Session::Backend::Redis;
use Moo::Role;

sub _build__jedi_session {
    my ($self) = @_;
    my $class = ref $self;
    my $expires_in = $self->jedi_config->{$class}{session_expiration} // '3 hours';
    my $redis_config = $self->jedi_config->{$class}{redis_config};
    return Jedi::Plugin::Session::Backend::Redis->new(redis_config => $redis_config, expires_in => $expires_in);
}

1;