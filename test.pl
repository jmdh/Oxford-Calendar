# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Oxford::Calendar;
$loaded = 1;
print "ok 1\n";

$Oxford::Calendar::testing++;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

print "n" unless Oxford::Calendar::ToOx(24,2,2002) eq "Sunday, 7th week, Hilary 2002.";
print "ok 2\n";
print "n" unless Oxford::Calendar::FromOx(
                    Oxford::Calendar::Parse("Sunday, 7th week, Hilary 2002"))
                 eq "24/2/2002";
print "ok 3\n";
