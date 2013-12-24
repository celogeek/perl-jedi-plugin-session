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
};

done_testing;