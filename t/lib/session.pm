package t::lib::session;
use Jedi::App;
use Jedi::Plugin::Session;

sub jedi_app {
  my ($app) = @_;
  $app->get('/uuid', sub {
    my ($app, $request, $response) = @_;
    $response->status(200);
    $response->body($request->{'Jedi::Plugin::Session::UUID'});
  });
}

1;