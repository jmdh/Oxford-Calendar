use strict;
use warnings;

use Test::More;
use Date::Calc;
use Oxford::Calendar;

# This is the extent of our data
my $base_epoch = @{&Oxford::Calendar::get_oxford_terms}[0]->[0];
my @base_ymd = (Date::Calc::Time_to_Date($base_epoch))[0,1,2];
my @end_ymd = (2012, 12, 31);
my $days = Date::Calc::Delta_Days(@base_ymd, @end_ymd);

#plan tests => 6 + $days + 1;
plan tests => 3;

my $testdate1 = 'Sunday, 7th week, Hilary 2002.';
is( Oxford::Calendar::ToOx(24,2,2002), $testdate1 );
TODO: {
    local $TODO = "Aaron's code not yet in";
#is( Oxford::Calendar::ToOx_strict(24,2,2002), $testdate1 );
#is( Oxford::Calendar::ToOx_loose(24,2,2002), $testdate1 );
#is( Oxford::Calendar::ToOx_nearest(24,2,2002), $testdate1 );
}
is( Oxford::Calendar::FromOx( Oxford::Calendar::Parse($testdate1)), "24/2/2002" );
# Check the new array mode
my @ary = Oxford::Calendar::ToOx(24,2,2002);
is( $ary[0], 'Sunday' );

TODO: {
    local $TODO = "Aaron's code not yet in";
# Check the new routines against the old
#foreach my $i (0.. $days ) {
#    my @t_ymd = Date::Calc::Add_Delta_Days(@base_ymd, $i);
#
#    my ($o, @oa) = ( Oxford::Calendar::ToOx( (reverse @t_ymd) ),
#                     Oxford::Calendar::ToOx( (reverse @t_ymd) ) );
#    my ($n, @na) = ( Oxford::Calendar::ToOx_nearest( (reverse @t_ymd) ),
#                     Oxford::Calendar::ToOx_nearest( (reverse @t_ymd) ) );
#
#    # The || is because there are some values for which new and old
#    # definitely don't agree (bug in old, e.g. 2007-12-20 (the old
#    # switching in the middle of a week from +n to -y)
#    #
#    ok( ($o eq $n)
#          || ( Oxford::Calendar::FromOx(reverse @oa)
#                 eq Oxford::Calendar::FromOx(reverse @na) ) );
# 
#}
}
