use strict;
use warnings;

use Test::More;
use Date::Calc;
use Oxford::Calendar;

# This is the extent of our data
my $base_epoch = @{&Oxford::Calendar::GetOxfordFullTerms}[0]->[0];
my @base_ymd = (Date::Calc::Time_to_Date($base_epoch))[0,1,2];
my $end_epoch = @{&Oxford::Calendar::GetOxfordFullTerms}[-1]->[0];
my @end_ymd = (Date::Calc::Time_to_Date($end_epoch))[0,1,2];
my $days = Date::Calc::Delta_Days(@base_ymd, @end_ymd);

plan tests => 13;

# Date in full term
my $testdate1 = 'Sunday, 7th week, Hilary 2002';
is( Oxford::Calendar::ToOx(24,2,2002, { mode => 'nearest' } ), $testdate1 );
is( Oxford::Calendar::ToOx(24,2,2002, { mode => 'ext_term' } ), $testdate1 );
is( Oxford::Calendar::ToOx(24,2,2002, { mode => 'full_term' } ), $testdate1 );
is( Oxford::Calendar::FromOx( Oxford::Calendar::Parse($testdate1)), "24/2/2002" );
# Check the array mode
my @ary = Oxford::Calendar::ToOx(24,2,2002);
is( $ary[0], 'Sunday' );

# Date in extended term
my $testdate2 = 'Friday, 9th week, Hilary 2008';
is( Oxford::Calendar::ToOx(14,3,2008, { mode => 'nearest' } ), $testdate2 );
is( Oxford::Calendar::ToOx(14,3,2008, { mode => 'ext_term' } ), $testdate2 );
is( Oxford::Calendar::ToOx(14,3,2008, { mode => 'full_term' } ), undef );
is( Oxford::Calendar::FromOx( Oxford::Calendar::Parse($testdate2)), "14/3/2008");

# Date not in term
my $testdate3 = 'Thursday, 11th week, Michaelmas 2007';
is( Oxford::Calendar::ToOx(20,12,2007, { mode => 'nearest' } ), $testdate3 );
is( Oxford::Calendar::ToOx(20,12,2007, { mode => 'ext_term' } ), undef );
is( Oxford::Calendar::ToOx(20,12,2007, { mode => 'full_term' } ), undef );
is( Oxford::Calendar::FromOx( Oxford::Calendar::Parse($testdate3)), "20/12/2007");
