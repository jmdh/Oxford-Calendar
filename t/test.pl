use strict;
use warnings;

use Test::More;

plan tests => 10;

BEGIN { use_ok( 'Oxford::Calendar' ); }
require_ok( 'Oxford::Calendar' );

is( Oxford::Calendar::ToOx(24,2,2002), "Sunday, 7th week, Hilary 2002." );
is( Oxford::Calendar::FromOx(
                    Oxford::Calendar::Parse("Sunday, 7th week, Hilary 2002")),
                 "24/2/2002" );
