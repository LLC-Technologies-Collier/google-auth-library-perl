package Google::Cloud::Transport::Adapter::NetCurl;

use strict;
use warnings;
use Moo;
use Scalar::Util qw(refaddr);
use Net::Curl::Easy qw(:constants);
use Net::Curl::Multi qw(:constants);
use Future;
use Carp qw(croak);
use Log::Any qw($log);

our $VERSION = '0.13';

with 'Google::Cloud::Transport::Role::Adapter';

has timeout => (
    is      => 'ro',
    default => sub { 30 },
);

has multi => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_multi',
);

sub _build_multi {
    my ($self) = @_;
    return Net::Curl::Multi->new();
}

# In a fully async environment, something needs to drive this Multi handle.
# For now, we implement a blocking fallback/driver internally if no external
# event loop integration is provided.

sub request {
    my ($self, %args) = @_;

    my $method  = uc($args{method} || 'GET');
    my $url     = $args{url} || $args{path};
    my $headers = $args{headers} || {};
    my $body    = $args{body};
    my $timeout = $args{timeout} // $self->timeout;

    unless ($url) {
        return Future->fail('URL/Path is required', 'Transport');
    }

    my $easy = Net::Curl::Easy->new();
    $easy->setopt(CURLOPT_URL, $url);
    
    if ($method eq 'POST') {
        $easy->setopt(CURLOPT_POST, 1);
    } elsif ($method eq 'PUT') {
        $easy->setopt(CURLOPT_PUT, 1); # Note: PUT might need more setup in libcurl
    } elsif ($method ne 'GET') {
        $easy->setopt(CURLOPT_CUSTOMREQUEST, $method);
    }

    my @curl_headers;
    while (my ($k, $v) = each %$headers) {
        if (ref($v) eq 'ARRAY') {
            for my $val (@$v) {
                push @curl_headers, $k . ': ' . $val;
            }
        } else {
            push @curl_headers, $k . ': ' . $v;
        }
    }
    $easy->setopt(CURLOPT_HTTPHEADER, \@curl_headers) if @curl_headers;

    if (defined $body) {
        my $body_str = ref($body) eq 'SCALAR' ? $$body : $body;
        $easy->setopt(CURLOPT_POSTFIELDS, $body_str);
        $easy->setopt(CURLOPT_POSTFIELDSIZE, length($body_str));
    }

    $easy->setopt(CURLOPT_TIMEOUT, $timeout) if defined $timeout;

    # Enable HTTP/2 if available
    eval {
        # CURLOPT_HTTP_VERSION is available in Net::Curl
        $easy->setopt(CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0);
    };

    my $response_body = '';
    $easy->setopt(CURLOPT_WRITEFUNCTION, sub {
        my ($easy, $data) = @_;
        $response_body .= $data;
        return length($data);
    });

    my %response_headers;
    $easy->setopt(CURLOPT_HEADERFUNCTION, sub {
        my ($easy, $header_line) = @_;
        if ($header_line =~ /^([^:]+):\s*(.*)\r\n$/) {
            my ($key, $val) = (lc($1), $2);
            # Handle duplicate headers if needed
            $response_headers{$key} = $val;
        }
        return length($header_line);
    });

    my $future = Future->new;

    # BLOCKING FALLBACK USING MULTI
    # This prepares the code for multi-handling but retains synchronous behavior.
    # To make this truly non-blocking, we would return the future immediately
    # and have an external event loop drive $self->multi.

    $log->debugf('Net::Curl: Dispatching %s %s', $method, $url) if $log;

    $self->multi->add_handle($easy);

    my $active = 1;
    while ($active) {
        $active = $self->multi->perform();
        if ($active) {
            my $timeout = $self->multi->timeout();
            $timeout = 1000 if $timeout < 0; # wait up to 1s if no timeout specified
            $self->multi->wait($timeout);
        }
    }

    my $curl_err;
    while (my ($msg, $msg_easy, $result) = $self->multi->info_read()) {
        if ($msg == CURLMSG_DONE && refaddr($msg_easy) == refaddr($easy)) {
            if ($result != CURLE_OK) {
                $curl_err = 'Curl error ' . $result;
            }
        }
    }

    $self->multi->remove_handle($easy);

    if ($curl_err) {
        $future->fail('Net::Curl perform failed: ' . $curl_err, 'Transport');
    } else {
        my $code = $easy->getinfo(CURLINFO_RESPONSE_CODE);
        if ($code >= 200 && $code < 300) {
            # Success
            # Wrap headers in a simple object or hash similar to LWP adapter
            # For consistency, let's use a simple hash or HTTP::Headers look-alike if needed.
            # But the role just says "headers", maybe a HashRef is fine.
            # The LWP adapter passes $res->headers which is an HTTP::Headers object.
            # We should probably be consistent.
            
            # Let's try to load HTTP::Headers for consistency if available,
            # otherwise just pass the HashRef.
            my $headers_obj;
            if (eval { require HTTP::Headers; 1 }) {
                $headers_obj = HTTP::Headers->new(%response_headers);
            } else {
                $headers_obj = \%response_headers;
            }

            $future->done($response_body, $headers_obj);
        } else {
            $future->fail('HTTP Error ' . $code, 'Transport', {
                code    => $code,
                body    => $response_body,
                headers => \%response_headers,
            });
        }
    }

    return $future;
}

sub start_stream {
    my ($self, %args) = @_;
    croak 'Streaming not implemented in NetCurl adapter yet';
}

1;

=head1 NAME

Google::Cloud::Transport::Adapter::NetCurl - Net::Curl Backend for Pluggable Transport

=head1 SYNOPSIS

    use Google::Cloud::Transport::Adapter::NetCurl;
    my $transport = Google::Cloud::Transport::Adapter::NetCurl->new();
    
    my $future = $transport->request(
        method => 'GET',
        url    => 'https://example.com',
    );
    
    my ($body, $headers) = $future->get();

=head1 DESCRIPTION

This adapter provides a transport implementation using Net::Curl.
It supports HTTP/2 if libcurl was compiled with it.

=cut
