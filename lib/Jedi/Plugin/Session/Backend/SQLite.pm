package Jedi::Plugin::Session::Backend::SQLite;

# ABSTRACT: Backend storage for SQLite

use strict;
use warnings;
# VERSION
use Time::Duration::Parse;
use Sereal qw/encode_sereal decode_sereal/;
use Path::Class;
use Carp;
use Jedi::Plugin::Session::Backend::SQLite::DB;
use DBIx::Class::Migration;
use Moo;

has 'database' => (
  is => 'ro',
  coerce => sub {
    my ($db) = @_;
    my $dbfile = file($db);
    $dbfile->dir->mkpath;
    return _prepare_database($dbfile);
  }
);

has 'expires_in' => (
  is => 'ro',
  default => sub {3*3600},
  coerce => sub { parse_duration($_[0]) }
);

## no critic (NamingConventions::ProhibitAmbiguousNames)

sub get {
  my ($self, $uuid) = @_;
  return if !defined $uuid;
  my $data = $self->database->resultset('Session')->find($uuid);
  my $session;
  if (defined $data) {
    return if ! eval { $session = decode_sereal($data->session); 1};
  }
  return $session;
}

sub set {
  my ($self, $uuid, $value) = @_;
  return if !defined $uuid;
  my $session = encode_sereal($value);
  $self->database->resultset('Session')->update_or_create({id => $uuid, expire_at => time + $self->expires_in, session => $session});
  return 1;
}

# PRIVATE

sub _prepare_database {
  my ($dbfile) = @_;
  my @connect_info = ("dbi:SQLite:dbname=" . $dbfile->stringify);
  my $schema = Jedi::Plugin::Session::Backend::SQLite::DB->connect(@connect_info);

  my $migration = DBIx::Class::Migration->new(
    schema => $schema,
  );

  $migration->install_if_needed;
  $migration->upgrade;

  return $schema;
}

1;