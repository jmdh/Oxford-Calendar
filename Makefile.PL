use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    (MM->can('signature_target') ? (SIGN => 1) : ()),
    'NAME'		    => 'Oxford::Calendar',
    'VERSION_FROM'	=> 'lib/Oxford/Calendar.pm', # finds $VERSION
    'PREREQ_PM'		=> {
        Text::Abbrev    => 0,
        Date::Calc      => 0,
        YAML            => 0,
        Time::Seconds   => 0,
        Test::More      => 0,
        Test::Exception => 0,
    }, # e.g., Module::Name => 1.1
);
