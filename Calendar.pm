# Oxford University calendar conversion.
# Simon Cozens (c) 1999-2002
# Eugene van der Pijll (c) 2004
# Artistic License
package Oxford::Calendar; 
$Oxford::Calendar::VERSION="1.7";
use strict;

=head1 NAME

Oxford::Calendar - Oxford calendar conversion routines

=head1 SYNOPSIS

    use Oxford::Calendar;
    print "Today is ", Oxford::Calendar::ToOx(reverse Date::Calc::Today);

=head1 DESCRIPTION

This module converts Oxford dates to and from Real World dates. It loads
the data from the University dates-of-term web page, although it is also 
possible to read data from a hash.

=cut

use Text::Abbrev;
use LWP::Simple ();
use Date::Calc qw(Decode_Date_EU);

my %db;

my $_initcal; # If this is true, we have our database of dates already.

our $testing = 0;

# Load up the calendar on demand.
sub _initcal {
	if ($testing or !Oxford::Calendar::InitHTML(LWP::Simple::get("http://www.admin.ox.ac.uk/admin/dates.shtml"))) {
		# OK, we have to do it ourselves.
		warn ("Couldn't load calendar") unless $testing;
		Oxford::Calendar::Init();
	}

	$_initcal++;
}

sub Init { 
    %db=(
            "Hilary 2001" => "14/01/2001",
            "Trinity 2001" => "22/04/2001",
            "Michaelmas 2001" => "07/10/2001",
            "Hilary 2002" => "13/01/2002",
            "Trinity 2002" => "21/04/2002",
            "Michaelmas 2002" => "13/10/2002",
            "Hilary 2003" => "19/01/2003",
            "Trinity 2003" => "27/04/2003",
            "Michaelmas 2003" => "12/10/2003",
            "Hilary 2004" => "18/01/2004",
            "Trinity 2004" => "25/04/2004",
            "Michaelmas 2004" => "10/10/2004",
            "Hilary 2005" => "16/01/2005",
            "Trinity 2005" => "24/04/2005",
            "Michaelmas 2005" => "09/10/2005",
            "Hilary 2006" => "15/01/2006",
            "Trinity 2006" => "23/04/2006",
            @_ );
} 

# This reads in the dates of term from the website, and tries to parse
# the details from there.
sub InitHTML {
    return 0 unless $_[0];
	$_[0]=~s/\r//g;
    s/<pre>\n//g;
	my @foo=split /\n/, $_[0];
	Init();
    my ($term, $year, $day, $month, $monthname);
	my $next=0;
	foreach (@foo) {
		last if /<h2>Dates of Extended Terms/; 
		# If they change the layout, of course...
		if (/TERM/) {($term, $year) = /\s*(\w+)\s+TERM (\d+)/; $next=1;}
		elsif ($next) { 
			$next=0; # <homer> Mmmm, counters. </homer>
			my ($date) = /^(.*?)\s\s/;
            $date=~s/,//g;
            $date.=$year;
            ($year, $month, $day) = Date::Calc::Decode_Date_EU($date);
			$term=ucfirst(lc($term));
			$db{$term." ".$year} =
			sprintf("%02u/%02u/%04u",$day,$month,$year) if $day and
			$month and $year;
			warn("parsed $term $year as $day $month $year") if $Oxford::Calendar::debug;
		}
	}
	return 1;
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
	my ($day,$month,$year) = @_;
	my $delta=367; my ($tmp, $offset);
	my @a;
    my ($nearest);
    die unless %db;
	foreach (keys %db) { 
		eval { @a=Date::Calc::Decode_Date_EU($db{$_}) } or die;
		next unless $a[2];
			if (abs($delta) > abs($tmp=Date::Calc::Delta_Days(
				@a,
				$year, $month, $day))) {
				$delta=$tmp;
				$nearest=$_; $offset=1;
			}
			if (abs($delta) > abs($tmp=Date::Calc::Delta_Days(
			    (Date::Calc::Add_Delta_Days(@a,7*7)),
				$year, $month, $day))) {
				$delta=$tmp;
				$nearest=$_; $offset=8;
            }
	}
	return "Out of my range" if $delta == 367;
	my $w=$offset+int($delta/7); $w-=1 if $delta<0 and $delta%7;
	if($delta<0){$delta=$delta%7-7}else{$delta%=7};
    my @days = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
	$day=$days[$delta];
	my $wsuffix="th";
	abs($w)==1 && ($wsuffix="st");
	abs($w)==2 && ($wsuffix="nd");
	abs($w)==3 && ($wsuffix="rd");
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
    my @days = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
	my $string = shift;
	my $term="";
	my ($day, $week, $year);
	$day=$week=$year="";

	$string=lc($string);
	$string=~s/week//g;
	my @terms = qw(Michaelmas Hilary Trinity);
	$string=~s/(\d+)(?:rd|st|nd|th)/$1/;
	my %ab=Text::Abbrev::abbrev(@days,@terms);
    my $expand;
	while ($string=~s/((?:\d|-)\d*)/ /) {
		if($1>50) { $year=$1; $year+=1900 if $year<1900; }
		else { $week=$1 }
		pos($string)-=length($1);
	}
	foreach(sort {length $b <=> length $a} keys %ab) {
		if ($string=~s/\b$_\w+//i) {
			#pos($string)-=length($_);
			#my $foo=lc($_); $string=~s/\G$foo[a-z]*/ /i; 
            $expand=$ab{$_};
			$term=$expand if (scalar(grep /$expand/, @terms) > 0) ;
			$day=$expand if (scalar (grep /$expand/, @days) > 0) ;
		}
	}
	unless ($day) {
		%ab=Text::Abbrev::abbrev(@days);
		foreach(sort {length $b <=> length $a} keys %ab) {
			if ($string=~/$_/ig) {
				pos($string)-=length($_);
				my $foo=lc($_); $string=~s/\G$foo[a-z]*/ /; $day=$ab{$_};
			}
		}
	}
	unless ($term) {
		%ab=Text::Abbrev::abbrev(@terms);
		foreach(sort {length $b <=> length $a} keys %ab) {
			if ($string=~/$_/ig) {
				pos($string)-=length($_);
				my $foo=lc($_); $string=~s/\G$foo[a-z]*/ /; $term=$ab{$_};
			}
		}
	}
	# Assume this term?
	unless($term) {
		$term=ToOx(reverse Date::Calc::Today());
		return "Can't work out what term" unless $term=~ /week/;
		$term=~s/.*eek,\s+(\w+).*/$1/;
	}
	$year=(Date::Calc::Today())[0] unless $year;
	return "UNPARSABLE" unless defined $week and defined $day;
	return($year,$term,$week,$day);
}

=item FromOx($year, $term, $week, $day)

Converts an Oxford date into a Georgian date, returning a string of the
form C<DD/MM/YYYY> or an error message.

=cut

sub FromOx {
    my @days = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
    my %lu;
	&_initcal unless defined $_initcal;
	my ($year, $term, $week, $day);
	($year, $term, $week, $day)=@_;
	$year=~s/\s//g;
	$term=~s/\s//g;
	return "Out of range " unless exists $db{"$term $year"};
	{ my $foo=0; %lu=(map {$_,$foo++} @days); }
	my $delta=7*($week-1)+$lu{$day};
	my @start=Date::Calc::Decode_Date_EU($db{"$term $year"});
	return "The internal database is bad for $term $year" unless
		$start[0];
	return
	join "/", reverse (Date::Calc::Add_Delta_Days(@start,$delta));

}

"A TRUE VALUE";

=head1 AUTHOR

Simon Cozens

Eugene van der Pijll, C<pijll@cpan.org>

