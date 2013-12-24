package Jedi::Plugin::Session::Backend::Redis;

# ABSTRACT: Backend storage for Redis

use strict;
use warnings;
# VERSION
use Time::Duration::Parse;
use Sereal qw/encode_sereal decode_sereal/;
use Redis;
use Moo;

has 'redis_config' => (
  is => 'ro',
  default => sub {{}},
  coerce => sub { ref $_[0] eq 'HASH' ? $_[0] : {} }
);

has 'expires_in' => (
  is => 'ro',
  default => sub {3*3600},
  coerce => sub { parse_duration($_[0]) }
);

has '_redis' => (
  is => 'lazy'
);

sub _build__redis {
  my ($self) = @_;
  return Redis->new(%{$self->redis_config});
}

## no critic (NamingConventions::ProhibitAmbiguousNames)
sub get {
  my ($self, $uuid) = @_;
  return if !defined $uuid;
  my $session = $self->_redis->get($uuid);
  if (defined $session) {
    return if ! eval { $session = decode_sereal($session); 1};
  }
  return $session;
}

sub set {
  my ($self, $uuid, $value) = @_;
  return if !defined $uuid;
  my $session = encode_sereal($value);
  $self->_redis->set($uuid, $session);
  $self->_redis->expire($uuid, $self->expires_in);
  return 1;
}


1;