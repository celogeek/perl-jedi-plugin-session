package t::lib::session_redis;
use Jedi::App;
use Jedi::Plugin::Session 'Redis';
with 't::lib::role';

sub jedi_app { shift->init_session }

1;