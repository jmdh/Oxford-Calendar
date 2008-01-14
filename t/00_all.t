use strict;
use warnings;

use Test::More;
use Date::Calc;
use Oxford::Calendar;

plan tests => 19;

# Date in full term
my $testdate1 = 'Sunday, 7th week, Hilary 2002';
is( Oxford::Calendar::ToOx(24, 2, 2002, { mode => 'nearest' } ), $testdate1 );
is( Oxford::Calendar::ToOx(24, 2, 2002, { mode => 'ext_term' } ), $testdate1 );
is( Oxford::Calendar::ToOx(24, 2, 2002, { mode => 'full_term' } ), $testdate1 );
is( Oxford::Calendar::FromOx( Oxford::Calendar::Parse($testdate1)), "24/2/2002" );
# Check the array mode
my @ary = Oxford::Calendar::ToOx(24,2,2002);
is( $ary[0], 'Sunday' );

# Date in extended term
my $testdate2 = 'Friday, 9th week, Hilary 2009';
is( Oxford::Calendar::ToOx(20, 3, 2009, { mode => 'nearest' } ), $testdate2 );
is( Oxford::Calendar::ToOx(20, 3, 2009, { mode => 'ext_term' } ), $testdate2 );
is( Oxford::Calendar::ToOx(20, 3, 2009, { mode => 'full_term' } ), undef );
is( Oxford::Calendar::FromOx( Oxford::Calendar::Parse($testdate2)), "20/3/2009");

# Date not in term
my $testdate3 = 'Thursday, 11th week, Michaelmas 2007';
is( Oxford::Calendar::ToOx(20, 12, 2007, { mode => 'nearest' } ), $testdate3 );
is( Oxford::Calendar::ToOx(20, 12, 2007, { mode => 'ext_term' } ), undef );
is( Oxford::Calendar::ToOx(20, 12, 2007, { mode => 'full_term' } ), undef );
is( Oxford::Calendar::FromOx( Oxford::Calendar::Parse($testdate3)), "20/12/2007");

# Some more dates
is( Oxford::Calendar::ToOx(12, 1, 2008, { mode => 'ext_term' } ),
    'Saturday, 0th week, Hilary 2008' );
is( Oxford::Calendar::ToOx(1, 1, 2008, { mode => 'ext_term' } ), undef );

my @next_term = Oxford::Calendar::NextTerm( 2008, 1, 1 );
is( $next_term[0], 2008 );
is( $next_term[1], 'Hilary' );
@next_term = Oxford::Calendar::NextTerm( 2008, 1, 14 );
is( $next_term[0], 2008 );
is( $next_term[1], 'Trinity' );

