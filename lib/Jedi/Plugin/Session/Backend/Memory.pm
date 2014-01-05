package Jedi::Plugin::Session::Backend::Memory;

# ABSTRACT: Backend storage for Memory

use strict;
use warnings;
# VERSION
use Time::Duration::Parse;
use Cache::LRU::WithExpires;
use Moo;

has '_cache' => (is => 'lazy');
sub _build__cache {
  return Cache::LRU::WithExpires->new;
}

has 'expires_in' => (
  is => 'ro',
  default => sub {3*3600},
  coerce => sub { parse_duration($_[0]) }
);

## no critic (NamingConventions::ProhibitAmbiguousNames)
sub get {
  my ($self, $uuid) = @_;
  return if !defined $uuid;

  return $self->_cache->get($uuid);
}

sub set {
  my ($self, $uuid, $value) = @_;
  return if !defined $uuid;
  $self->_cache->set($uuid, $value, $self->expires_in);
  return 1;
}

1;