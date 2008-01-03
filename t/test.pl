use strict;
use warnings;

use Test::More;

plan tests => 4;

use_ok( 'Oxford::Calendar' );
require_ok( 'Oxford::Calendar' );

my $testdate1 = 'Sunday, 7th week, Hilary 2002.';
is( Oxford::Calendar::ToOx(24,2,2002), $testdate1 );
is( Oxford::Calendar::FromOx( Oxford::Calendar::Parse($testdate1)), "24/2/2002" );
