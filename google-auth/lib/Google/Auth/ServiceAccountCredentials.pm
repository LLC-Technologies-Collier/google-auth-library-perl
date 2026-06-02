# Copyright 2022 Google, LLC
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

package Google::Auth::ServiceAccountCredentials;

use strict;
use warnings;

use Moo;
use JSON::PP;

our $VERSION = '0.02';

has json_key => (
    is       => 'ro',
    required => 0,
);

has project_id => (
    is       => 'ro',
    required => 0,
);

has private_key_id => (
    is       => 'ro',
    required => 0,
);

has private_key => (
    is       => 'ro',
    required => 0,
);

has client_email => (
    is       => 'ro',
    required => 0,
);

has client_id => (
    is       => 'ro',
    required => 0,
);

has auth_uri => (
    is       => 'ro',
    required => 0,
);

has token_uri => (
    is       => 'ro',
    required => 0,
);

has auth_provider_x509_cert_url => (
    is       => 'ro',
    required => 0,
);

has client_x509_cert_url => (
    is       => 'ro',
    required => 0,
);

around BUILDARGS => sub {
    my ( $orig, $class, @args ) = @_;
    my $args = $class->$orig(@args);

    if ( my $json = $args->{json_key} ) {
        $args->{project_id}                  //= $json->{project_id};
        $args->{private_key_id}              //= $json->{private_key_id};
        $args->{private_key}                 //= $json->{private_key};
        $args->{client_email}                //= $json->{client_email};
        $args->{client_id}                   //= $json->{client_id};
        $args->{auth_uri}                    //= $json->{auth_uri};
        $args->{token_uri}                   //= $json->{token_uri};
        $args->{auth_provider_x509_cert_url} //= $json->{auth_provider_x509_cert_url};
        $args->{client_x509_cert_url}        //= $json->{client_x509_cert_url};
    }

    return $args;
};

1;

