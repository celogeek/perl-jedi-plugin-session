package t::lib::session_sqlite;
use strict;
use warnings;
use Path::Class 0.33;
use Jedi::App;
use Jedi::Plugin::Session 'SQLite';
with 't::lib::role';

sub jedi_app { 
  my ($app) = @_;
  $app->jedi_config->{'t::lib::session_sqlite'}{'session'}{'sqlite'}{'path'} =  Path::Class::tempdir(CLEANUP => 1);
  $app->init_session;
}

1;