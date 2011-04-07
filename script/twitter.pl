#!perl
use utf8;
use strict;
use warnings;

use Config::Pit;
use File::Basename;
use AnyEvent;
use AnyEvent::Twitter::Stream;
use Encode;
use Encode::Locale;
use IPC::Run qw(run);

my $server = shift;
my $config = pit_get('api.twitter.com');
my $cv     = AE::cv;

my $listener = AnyEvent::Twitter::Stream->new(
    %$config,
    method   => 'userstream',
    on_tweet => sub {
        my $tweet = shift;
        if ($tweet->{user}) {
            my $message = $tweet->{user}{screen_name}.': '.$tweet->{text};
            $message = Encode::encode('console_out', $message);
            $message =~ s!'!''!;
            run dirname(__FILE__).'/vimremote',
              '--servername', $server,
              '--remote-expr', "twitternotify#notify('$message')";
        }
    },
    on_eof => sub {
        $cv->send;
    },
);

$cv->recv;

