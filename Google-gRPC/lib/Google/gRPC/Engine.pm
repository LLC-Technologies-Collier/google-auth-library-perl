package Google::gRPC::Engine;

use strict;
use warnings;
use Carp qw(croak);

sub create {
    my ($class, %args) = @_;
    my $preferred = delete $args{engine};

    if (defined $preferred) {
        if ($preferred eq 'NGHTTP2') {
            require Google::gRPC::Engine::NGHTTP2;
            return Google::gRPC::Engine::NGHTTP2->new(%args);
        }
        elsif ($preferred eq 'PP') {
            require Google::gRPC::Engine::PP;
            return Google::gRPC::Engine::PP->new(%args);
        }
    }

    eval {
        require Google::gRPC::Engine::NGHTTP2;
        my $eng = Google::gRPC::Engine::NGHTTP2->new(%args);
        return $eng if $eng;
    };

    require Google::gRPC::Engine::PP;
    return Google::gRPC::Engine::PP->new(%args);
}

1;
