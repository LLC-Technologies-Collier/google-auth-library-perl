package Google::Cloud::REST::Client;

use strict;
use warnings;
use Moo;
extends 'Google::Cloud::ClientBase';
use LWP::UserAgent;
use HTTP::Request;
use JSON::MaybeXS qw(encode_json decode_json);
use Carp qw(croak);
use Log::Any qw($log);
use Time::HiRes qw(sleep);

our $VERSION = '0.04';

has target => (
    is       => 'ro',
    required => 1,
);

has auth_token => (
    is       => 'ro',
    required => 0,
);

has timeout => (
    is      => 'ro',
    default => sub { 30 },
);

has max_retries => (
    is      => 'ro',
    default => sub { 3 },
);

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;
    my $h = $class->$orig(@args);
    if (exists $h->{ua} && !exists $h->{user_agent}) {
        $h->{user_agent} = delete $h->{ua};
    }
    return $h;
};

has user_agent => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_user_agent',
);


sub _build_transport {
    my ($self) = @_;
    require Google::Cloud::Transport::Adapter::LWP;
    return Google::Cloud::Transport::Adapter::LWP->new(user_agent => $self->user_agent);
}

sub _build_user_agent {
    my ($self) = @_;
    my $ua = LWP::UserAgent->new(
        timeout => $self->timeout,
        agent   => 'google-cloud-perl-rest/' . $VERSION,
    );
    return $ua;
}

sub ua { my $s = shift; return $s->user_agent(@_); }

sub call {
    my ($self, $args) = @_;
    if (@_ > 2 && scalar(@_) % 2 == 1) {
        my ($s, %kw) = @_;
        $args = \%kw;
    }

    my $http_method    = uc($args->{http_method} || $args->{method} || 'POST');
    my $path           = $args->{path} || $args->{url} || '';
    my $request_obj    = $args->{request};
    my $response_class = $args->{response_class};
    my $query_params   = $args->{query_params} || {};

    # Build full URL
    my $base_url = $self->target;
    unless ($base_url =~ /^https?:\/\//) {
        $base_url = 'https://' . $base_url;
    }
    $base_url =~ s/\/+$//;

    if ($path) {
        $path =~ s/^\/+//;
        $base_url .= '/' . $path;
    }

    # Append query parameters if any
    if (keys %$query_params) {
        my @pairs;
        for my $k (sort keys %$query_params) {
            push @pairs, sprintf('%s=%s', $k, $query_params->{$k});
        }
        $base_url .= '?' . join('&', @pairs);
    }

    # Build HTTP request
    my $req = HTTP::Request->new($http_method => $base_url);
    $req->header('Content-Type' => 'application/json');

    # Add Authorization token
    my $token = $self->auth_token;
    if ($token) {
        if (ref($token) && eval { $token->can('get_token') }) {
            $token = $token->get_token();
        }
        $req->header('Authorization' => 'Bearer ' . $token);
    }

    # Encode body
    if ($request_obj) {
        my $encoded = $self->encode_payload($request_obj, 'json');
        $req->content($encoded) if defined $encoded && length $encoded;
    }

    # Execute HTTP request with retries
    my $retries = 0;
    my $content;
    my $backoff = 0.1;

    while (1) {
        $log->debugf('REST Request: %s %s', $http_method, $base_url);
        
        my %headers_hash;
        $req->headers->scan(sub {
            my ($k, $v) = @_;
            $headers_hash{$k} = $v;
        });

        my %transport_args = (
            method  => $http_method,
            url     => $base_url,
            headers => \%headers_hash,
            timeout => $self->timeout,
        );
        if (defined $req->content && length $req->content) {
            $transport_args{body} = $req->content;
        }

        my $future = $self->transport->request(%transport_args);
        
        # BLOCKING WAIT
        my $future_res = eval { $future->get() };
        my $err = $@;

        if (!$err) {
            my ($body, $headers) = $future->get();
            $content = $body;
            last;
        } else {
            my ($err_msg, $cat, $details) = $future->failure;
            my $code = 0;
            my $status_line = $err_msg;
            my $error_body = '';

            if (ref($details) eq 'HASH') {
                $code = $details->{code} // 0;
                $error_body = $details->{body} // '';
            } elsif (eval { $details->can('code') }) {
                $code = $details->code // 0;
                $status_line = $details->status_line // $err_msg;
                $error_body = $details->content // '';
            }

            if (($code == 502 || $code == 503 || $code == 504) && $retries < $self->max_retries) {
                $retries++;
                $log->warnf('REST Transient HTTP %d response, retrying (%d/%d) in %.2fs...', $code, $retries, $self->max_retries, $backoff);
                sleep($backoff);
                $backoff *= 2.0;
                next;
            }

            # Unrecoverable error
            my $final_err_msg = sprintf('REST API HTTP Error %d: %s', $code, $status_line);
            if ($error_body) {
                $final_err_msg .= ' - ' . $error_body;
            }
            croak $final_err_msg;
        }
    }
    return $self->decode_payload($content, 'json', $response_class);
}

*request = \&call;

1;
