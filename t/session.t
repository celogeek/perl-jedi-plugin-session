#!perl
use Test::Most 'die';
use HTTP::Request::Common;
use Plack::Test;
use Jedi;

my $jedi = Jedi->new();
$jedi->road('/' => 't::lib::session');

test_psgi $jedi->start, sub {
        my $cb = shift;
        {
                my $res = $cb->(GET '/uuid');
                is $res->code, 200, 'status ok';
                my $cookie = $res->headers->header('set-cookie');
                like $cookie, qr{jedi_session=.{12};}, 'cookie ok';
                is length($res->content), 27, '... and also the content';
        }
        {
          my $res = $cb->(HTTP::Request->new(
            'GET' => '/uuid', HTTP::Headers->new(
              'Cookie' => 'jedi_session=123456789012;'
            )
          ));
          my $content = $res->content;
          $res = $cb->(HTTP::Request->new(
            'GET' => '/uuid', HTTP::Headers->new(
              'Cookie' => 'jedi_session=123456789012;'
            )
          ));
          is $res->content, $content, 'content still the same';
          $res = $cb->(HTTP::Request->new(
            'GET' => '/uuid', HTTP::Headers->new(
              'Cookie' => 'jedi_session=123456789013;'
            )
          ));
          ok $res->content ne $content, 'content change with another session';

          $res = $cb->(HTTP::Request->new(
            'GET' => '/uuid', HTTP::Headers->new(
              'Cookie' => 'jedi_session=123456789012;',
              'X_FORWARDED_FOR' => '11.0.0.1',
            )
          ));
          ok $res->content ne $content, 'content change with different ip';
          $content = $res->content;

          $res = $cb->(HTTP::Request->new(
            'GET' => '/uuid', HTTP::Headers->new(
              'Cookie' => 'jedi_session=123456789012;',
              'X_FORWARDED_FOR' => '11.0.0.1',
            )
          ));
          is $res->content, $content, 'uuid is the same for the same ip';
        }

        {
          my $res = $cb->(HTTP::Request->new(
            'GET' => '/set', HTTP::Headers->new(
              'Cookie' => 'jedi_session=123456789014;'
            )
          ));
          is $res->content, 'ko', 'nothing to set';

          $res = $cb->(HTTP::Request->new(
            'GET' => '/set?k=a', HTTP::Headers->new(
              'Cookie' => 'jedi_session=123456789014;'
            )
          ));
          is $res->content, 'ok', 'value set to undef';

          $res = $cb->(HTTP::Request->new(
            'GET' => '/set?k=a&v=1', HTTP::Headers->new(
              'Cookie' => 'jedi_session=123456789014;'
            )
          ));
          is $res->content, 'ok', 'value set to 1';

          $res = $cb->(HTTP::Request->new(
            'GET' => '/set?k=a&v=2', HTTP::Headers->new(
              'Cookie' => 'jedi_session=123456789014;'
            )
          ));
          is $res->content, 'ok', 'value set to 2';

          $res = $cb->(HTTP::Request->new(
            'GET' => '/get?k=a', HTTP::Headers->new(
              'Cookie' => 'jedi_session=123456789014;'
            )
          ));
          is $res->content, '2', 'value get is 2';

          $res = $cb->(HTTP::Request->new(
            'GET' => '/get?k=a', HTTP::Headers->new(
              'Cookie' => 'jedi_session=123456789014;',
              'X_FORWARDED_FOR' => '11.0.0.1',
            )
          ));
          is $res->content, 'undef', 'another user, same session, diff ip';
        }
};

done_testing;