use strict;
use warnings;
use Test::More;
use Test::LWP::UserAgent;
use HTTP::Response;

use Google::Cloud::Transport::Adapter::LWP;

my $mock_ua = Test::LWP::UserAgent->new;
$mock_ua->map_response(
    qr{example.com/success} => HTTP::Response->new(200, 'OK', ['Content-Type' => 'text/plain'], 'Success Body')
);
$mock_ua->map_response(
    qr{example.com/fail} => HTTP::Response->new(500, 'Internal Server Error', ['Content-Type' => 'text/plain'], 'Error Body')
);

my $adapter = Google::Cloud::Transport::Adapter::LWP->new(user_agent => $mock_ua);

subtest 'Success request' => sub {
    my $future = $adapter->request(
        method => 'GET',
        url    => 'https://example.com/success',
    );
    
    ok($future, 'Got a future');
    ok($future->is_ready, 'Future is ready immediately (blocking transport)');
    
    my ($body, $headers) = $future->get();
    is($body, 'Success Body', 'Correct body');
    is($headers->header('Content-Type'), 'text/plain', 'Correct headers');
};

subtest 'Failed request' => sub {
    my $future = $adapter->request(
        method => 'GET',
        url    => 'https://example.com/fail',
    );
    
    ok($future, 'Got a future');
    ok($future->is_ready, 'Future is ready immediately');
    
    ok($future->is_failed, 'Future failed');
    
    my ($err, $cat, $res) = $future->failure;
    is($err, '500 Internal Server Error', 'Correct error message');
    is($cat, 'Transport', 'Correct category');
    isa_ok($res, 'HTTP::Response', 'Response object included');
};

done_testing();
