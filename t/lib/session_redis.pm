package t::lib::session_redis;
use Jedi::App;
use Jedi::Plugin::Session 'Redis';
with 't::lib::role';

my $app_id = 0;

sub jedi_app { 
  my ($app) = @_;
  $app->jedi_config->{'t::lib::session_redis'}{'session'}{'redis'}{'prefix'} = 'test_' . (++$app_id);
  $app->init_session;
}

1;