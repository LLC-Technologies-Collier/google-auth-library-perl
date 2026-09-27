package Google::Cloud::Transport::Adapter::LWP;

use strict;
use warnings;
use Moo;
use LWP::UserAgent;
use HTTP::Request;
use Future;
use Carp qw(croak);

our $VERSION = '0.13';

with 'Google::Cloud::Transport::Role::Adapter';

has user_agent => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_user_agent',
);

has timeout => (
    is      => 'ro',
    default => sub { 30 },
);

sub _build_user_agent {
    my ($self) = @_;
    return LWP::UserAgent->new(
        timeout => $self->timeout,
        agent   => 'google-cloud-perl-transport-lwp/' . $VERSION,
    );
}

sub request {
    my ($self, %args) = @_;
    
    my $method  = uc($args{method} || 'GET');
    my $url     = $args{url} || $args{path};
    my $headers = $args{headers} || {};
    my $body    = $args{body};
    my $timeout = $args{timeout};

    unless ($url) {
        return Future->fail('URL/Path is required', 'Transport');
    }

    my $req = HTTP::Request->new($method => $url);
    
    while (my ($k, $v) = each %$headers) {
        $req->header($k => $v);
    }

    if (defined $body) {
        $req->content(ref($body) eq 'SCALAR' ? $$body : $body);
    }

    # Clone UA to set timeout if specified per-request, to avoid race conditions
    # if the adapter is shared across threads/async tasks (though LWP is blocking).
    my $ua = $self->user_agent;
    if (defined $timeout) {
        $ua = $ua->clone;
        $ua->timeout($timeout);
    }

    my $res = $ua->request($req);

    my $future = Future->new;
    
    if ($res->is_success) {
        $future->done($res->content, $res->headers);
    } else {
        # We might want to pass more structured error info
        $future->fail($res->status_line, 'Transport', $res);
    }

    return $future;
}

sub start_stream {
    my ($self, %args) = @_;
    croak 'Streaming not supported by LWP adapter';
}

1;

=head1 NAME

Google::Cloud::Transport::Adapter::LWP - LWP Backend for Pluggable Transport

=head1 SYNOPSIS

    use Google::Cloud::Transport::Adapter::LWP;
    my $transport = Google::Cloud::Transport::Adapter::LWP->new();
    
    my $future = $transport->request(
        method => 'GET',
        url    => 'https://example.com',
    );
    
    my ($body, $headers) = $future->get();

=head1 DESCRIPTION

This adapter provides a blocking transport implementation using LWP::UserAgent.
It is intended for backward compatibility and environments without async requirements.

=cut
