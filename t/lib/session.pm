package t::lib::session;
use Jedi::App;
use Jedi::Plugin::Session;
with 't::lib::role';

sub jedi_app { shift->init_session }

1;