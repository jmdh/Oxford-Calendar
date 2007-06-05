# Oxford University calendar conversion.
# Simon Cozens (c) 1999-2002
# Eugene van der Pijll (c) 2004
# Dominic Hargreaves / University of Oxford (c) 2007
# Artistic License
package Oxford::Calendar;
$Oxford::Calendar::VERSION = "1.8";
use strict;

use constant CALENDAR => '/etc/oxford-calendar.yaml';

=head1 NAME

Oxford::Calendar - Oxford calendar conversion routines

=head1 SYNOPSIS

    use Oxford::Calendar;
    print "Today is ", Oxford::Calendar::ToOx(reverse Date::Calc::Today);

=head1 DESCRIPTION

This module converts Oxford dates to and from Real World dates using data
supplied in YAML data.

If the file /etc/oxford-calendar.yaml exists, data will be read from that;
otherwise, built-in data will be used.

=cut

use Text::Abbrev;
use Date::Calc qw(Decode_Date_EU);
use YAML;

our %db;

my $_initcal;    # If this is true, we have our database of dates already.

# Load up the calendar on demand.
sub _initcal {
    Oxford::Calendar::Init();
}

sub Init {
    my $db;
    if ( -r CALENDAR ) {
        $db = YAML::LoadFile(CALENDAR);
    }
    else {
        my $data = join '', <DATA>;
        $db = YAML::Load($data);
    }
    %db = %{ $db->{Calendar} };
    $_initcal++;
}

sub InitHTML {
    die "This method is no longer suported";
}

=head1 Functions

=over 3

=item ToOx($day, $month, $year)

Given a day, month and year in standard human format (that is, month is
1-12, not 0-11, and year is four digits) will return a string of the
form

    Day, xth week, Term.

or, on error, the text C<Out of range>.

=cut

sub ToOx {
    &_initcal unless defined $_initcal;
    my ( $day, $month, $year ) = @_;
    my $delta = 367;
    my ( $tmp, $offset );
    my @a;
    my ($nearest);
    die unless %db;
    foreach ( keys %db ) {
        eval { @a = Date::Calc::Decode_Date_EU( $db{$_} ) } or die;
        next unless $a[2];
        if (abs($delta)
            > abs( $tmp = Date::Calc::Delta_Days( @a, $year, $month, $day ) )
            )
        {
            $delta   = $tmp;
            $nearest = $_;
            $offset  = 1;
        }
        if (abs($delta) > abs(
                $tmp = Date::Calc::Delta_Days(
                    ( Date::Calc::Add_Delta_Days( @a, 7 * 7 ) ),
                    $year, $month, $day
                )
            )
            )
        {
            $delta   = $tmp;
            $nearest = $_;
            $offset  = 8;
        }
    }
    return "Out of my range" if $delta == 367;
    my $w = $offset + int( $delta / 7 );
    $w -= 1 if $delta < 0 and $delta % 7;
    if ( $delta < 0 ) { $delta = $delta % 7 - 7 }
    else { $delta %= 7 }
    my @days = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
    $day = $days[$delta];
    my $wsuffix = "th";
    abs($w) == 1 && ( $wsuffix = "st" );
    abs($w) == 2 && ( $wsuffix = "nd" );
    abs($w) == 3 && ( $wsuffix = "rd" );
    return "$day, $w$wsuffix week, $nearest.";
}

=item Parse($string)

Takes a free-form description of an Oxford calendar date, and attempts
to divine the expected meaning. If the name of a term is not found, the
current term will be assumed. If the description is unparsable, the text
C<"UNPARSABLE"> is returned.  Otherwise, output is of the form
C<($year,$term,$week,$day)>

This function is experimental.

=cut

sub Parse {
    my @days   = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
    my $string = shift;
    my $term   = "";
    my ( $day, $week, $year );
    $day = $week = $year = "";

    $string = lc($string);
    $string =~ s/week//g;
    my @terms = qw(Michaelmas Hilary Trinity);
    $string =~ s/(\d+)(?:rd|st|nd|th)/$1/;
    my %ab = Text::Abbrev::abbrev( @days, @terms );
    my $expand;
    while ( $string =~ s/((?:\d|-)\d*)/ / ) {
        if ( $1 > 50 ) { $year = $1; $year += 1900 if $year < 1900; }
        else { $week = $1 }
    }
    foreach ( sort { length $b <=> length $a } keys %ab ) {
        if ( $string =~ s/\b$_\w+//i ) {

            #pos($string)-=length($_);
            #my $foo=lc($_); $string=~s/\G$foo[a-z]*/ /i;
            $expand = $ab{$_};
            $term   = $expand if ( scalar( grep /$expand/, @terms ) > 0 );
            $day    = $expand if ( scalar( grep /$expand/, @days ) > 0 );
        }
    }
    unless ($day) {
        %ab = Text::Abbrev::abbrev(@days);
        foreach ( sort { length $b <=> length $a } keys %ab ) {
            if ( $string =~ /$_/ig ) {
                pos($string) -= length($_);
                my $foo = lc($_);
                $string =~ s/\G$foo[a-z]*/ /;
                $day = $ab{$_};
            }
        }
    }
    unless ($term) {
        %ab = Text::Abbrev::abbrev(@terms);
        foreach ( sort { length $b <=> length $a } keys %ab ) {
            if ( $string =~ /$_/ig ) {
                pos($string) -= length($_);
                my $foo = lc($_);
                $string =~ s/\G$foo[a-z]*/ /;
                $term = $ab{$_};
            }
        }
    }

    # Assume this term?
    unless ($term) {
        $term = ToOx( reverse Date::Calc::Today() );
        return "Can't work out what term" unless $term =~ /week/;
        $term =~ s/.*eek,\s+(\w+).*/$1/;
    }
    $year = ( Date::Calc::Today() )[0] unless $year;
    return "UNPARSABLE" unless defined $week and defined $day;
    return ( $year, $term, $week, $day );
}

=item FromOx($year, $term, $week, $day)

Converts an Oxford date into a Georgian date, returning a string of the
form C<DD/MM/YYYY> or an error message.

=cut

sub FromOx {
    my @days = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
    my %lu;
    &_initcal unless defined $_initcal;
    my ( $year, $term, $week, $day );
    ( $year, $term, $week, $day ) = @_;
    $year =~ s/\s//g;
    $term =~ s/\s//g;
    return "Out of range " unless exists $db{"$term $year"};
    {
        my $foo = 0;
        %lu = ( map { $_, $foo++ } @days );
    }
    my $delta = 7 * ( $week - 1 ) + $lu{$day};
    my @start = Date::Calc::Decode_Date_EU( $db{"$term $year"} );
    return "The internal database is bad for $term $year"
        unless $start[0];
    return join "/", reverse( Date::Calc::Add_Delta_Days( @start, $delta ) );

}

"A TRUE VALUE";

=head1 AUTHOR

Simon Cozens

Eugene van der Pijll, C<pijll@cpan.org>

Dominic Hargreaves

=cut

__DATA__
--- #YAML:1.0
Calendar:
  Hilary 2001: 14/01/2001
  Hilary 2002: 13/01/2002
  Hilary 2003: 19/01/2003
  Hilary 2004: 18/01/2004
  Hilary 2005: 16/01/2005
  Hilary 2006: 15/01/2006
  Hilary 2007: 14/01/2007
  Hilary 2008: 13/01/2008
  Hilary 2009: 18/01/2009
  Hilary 2010: 17/01/2010
  Hilary 2011: 16/01/2011
  Hilary 2012: 15/01/2012
  Hilary 2013: 13/01/2013
  Michaelmas 2001: 07/10/2001
  Michaelmas 2002: 13/10/2002
  Michaelmas 2003: 12/10/2003
  Michaelmas 2004: 10/10/2004
  Michaelmas 2005: 09/10/2005
  Michaelmas 2006: 08/10/2006
  Michaelmas 2007: 07/10/2007
  Michaelmas 2008: 12/10/2008
  Michaelmas 2009: 11/10/2009
  Michaelmas 2010: 10/10/2010
  Michaelmas 2011: 09/10/2011
  Michaelmas 2012: 07/10/2012
  Trinity 2001: 22/04/2001
  Trinity 2002: 21/04/2002
  Trinity 2003: 27/04/2003
  Trinity 2004: 25/04/2004
  Trinity 2005: 24/04/2005
  Trinity 2006: 23/04/2006
  Trinity 2007: 22/04/2007
  Trinity 2008: 20/04/2008
  Trinity 2009: 26/04/2009
  Trinity 2010: 25/04/2010
  Trinity 2011: 01/05/2011
  Trinity 2012: 22/04/2012
  Trinity 2013: 21/04/2013
