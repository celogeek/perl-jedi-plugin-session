package Jedi::Plugin::Session::Role::SQLite;

# ABSTRACT: SQLite Backend

use strict;
use warnings;
# VERSION

use File::ShareDir;
use Path::Class;
use Carp;
use Jedi::Plugin::Session::Backend::SQLite;
use Moo::Role;

sub _build__jedi_session {
    my ($self) = @_;
    my $class = ref $self;
    my $expires_in = $self->jedi_config->{$class}{session}{expiration} // '3 hours';
    my $sqlite_path = $self->jedi_config->{$class}{session}{sqlite}{path};
    if (!defined $sqlite_path) {
      $sqlite_path = dir(File::ShareDir::dist_dir('Jedi-Plugin-Session'));
    }
    croak "SQLite path is missing and cannot be guest. Please setup the configuration file."
     if !defined $sqlite_path;
    my $app_dir = dir($sqlite_path, split(/::/x, $class));
    my $sqlite_db_file = file($app_dir . '.db');
    return Jedi::Plugin::Session::Backend::SQLite->new(
      database => $sqlite_db_file,
      expires_in => $expires_in,
    );
}

1;