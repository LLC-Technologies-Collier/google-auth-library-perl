#!/perl -T
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Exception;

use Google::Auth;

subtest 'generating self-signed certificate in-process via OpenSSL' => sub {
    my $result = eval { Google::Auth::generate_self_signed_cert() };
    is( $@, '', 'no exception thrown' );
    ok( defined $result, 'returned result is defined' );
    is( ref $result, 'HASH', 'returned result is a hash reference' );
    ok( exists $result->{cert}, 'hash contains cert' );
    ok( exists $result->{key}, 'hash contains key' );

    like( $result->{cert}, qr/-----BEGIN CERTIFICATE-----/, 'cert contains PEM header' );
    like( $result->{key}, qr/-----BEGIN PRIVATE KEY-----/, 'key contains PEM header' );
};

done_testing();
