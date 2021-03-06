package t::lib::role;
use Moo::Role;

sub init_session {
  my ($app) = @_;
  $app->get('/uuid', sub {
    my ($app, $request, $response) = @_;
    $response->status(200);
    $response->body($request->{'Jedi::Plugin::Session::UUID'});
  });

  $app->get('/set', sub {
    my ($app, $request, $response) = @_;
    my $session = $request->session_get // {};
    my $k = $request->params->{'k'};
    my $v = $request->params->{'v'};

    $response->status(200);

    if (defined $k) {
      $session->{$k} = $v;
      $request->session_set($session);
      $response->body('ok');
    } else {
      $response->body('ko');
    }
  });

  $app->get('/get', sub {
    my ($app, $request, $response) = @_;
    my $session = $request->session_get // {};
    my $k = $request->params->{'k'};
    my $session_val;
    if (defined $k) {
      $session_val = $session->{$k};
    }
    $response->status(200);
    $response->body(defined $session_val ? $session_val : "undef");
  });

}

1;