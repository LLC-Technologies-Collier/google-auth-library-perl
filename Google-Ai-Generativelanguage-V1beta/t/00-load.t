#!perl
use 5.008003;
use strict;
use warnings;
use Test::More;

plan tests => 10;

BEGIN {
    use_ok( 'Google::Ai::Generativelanguage::V1beta' ) || print "Bail out!\n";
    use_ok( 'Google::Ai::Generativelanguage::CacheServiceClient' ) || print "Bail out!\n";
    use_ok( 'Google::Ai::Generativelanguage::DiscussServiceClient' ) || print "Bail out!\n";
    use_ok( 'Google::Ai::Generativelanguage::FileServiceClient' ) || print "Bail out!\n";
    use_ok( 'Google::Ai::Generativelanguage::GenerativeServiceClient' ) || print "Bail out!\n";
    use_ok( 'Google::Ai::Generativelanguage::ModelServiceClient' ) || print "Bail out!\n";
    use_ok( 'Google::Ai::Generativelanguage::PermissionServiceClient' ) || print "Bail out!\n";
    use_ok( 'Google::Ai::Generativelanguage::PredictionServiceClient' ) || print "Bail out!\n";
    use_ok( 'Google::Ai::Generativelanguage::RetrieverServiceClient' ) || print "Bail out!\n";
    use_ok( 'Google::Ai::Generativelanguage::TextServiceClient' ) || print "Bail out!\n";
}

diag( "Testing Google::Ai::Generativelanguage::V1beta $Google::Ai::Generativelanguage::V1beta::VERSION, Perl $], $^X" );
