package Jedi::Plugin::Session::Role::Memory;

# ABSTRACT: Memory Backend

use strict;
use warnings;
# VERSION

use Moo::Role;

sub _build__jedi_session {
    my ($self) = @_;
    my $class = ref $self;
    my $expires_in = $self->jedi_config->{$class}{session}{expiration} // '3 hours';
    return CHI->new(driver => 'Memory', datastore => {}, expires_in => $expires_in);
}

1;