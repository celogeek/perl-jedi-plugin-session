package t::lib::session_redis;
use Jedi::App;
use Jedi::Plugin::Session 'Redis';
with 't::lib::role';

my $app_id = 0;

sub jedi_app { 
  my ($app) = @_;
  $app->init_session;
  $app->_jedi_session->prefix('test_' . (++$app_id));
}

1;