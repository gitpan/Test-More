# A template for Makefile.PL used by Arena Networks.
# - Set the $PACKAGE variable to the name of your module.
# - Set $LAST_API_CHANGE to reflect the last version you changed the API 
#   of your module.
# - Fill in your dependencies in PREREQ_PM
# Alternatively, you can say the hell with this and use h2xs.

use ExtUtils::MakeMaker;

$PACKAGE = 'Test::More';
($PACKAGE_FILE = $PACKAGE) =~ s|::|/|g;
$LAST_API_CHANGE = 0;

eval "require $PACKAGE";

unless ($@) { # Make sure we did find the module.
    print <<"CHANGE_WARN" if ${$PACKAGE.'::VERSION'} < $LAST_API_CHANGE;

NOTE: There have been API changes between this version and any older
than version $LAST_API_CHANGE!  Please read the Changes file if you
are upgrading from a version older than $LAST_API_CHANGE.

CHANGE_WARN
}


die <<DEAD;
************************************************************************
Test::More is now distributed in the Test::Simple tarball.  This is
NOT a new version.  There will be no more seperate Test::More
distributions.

If you want a new version, download the latest Test::Simple tarball.
Better yet, use the CPAN shell and it'll just figure it out for you.

This installation will now puke and die.
************************************************************************
DEAD

WriteMakefile(
    NAME            => $PACKAGE,
    VERSION_FROM    => "lib/$PACKAGE_FILE.pm", # finds $VERSION
    PREREQ_PM       => { Test::Simple   => 0.09,
                         Test::Harness  => 1.22,
                       },
    'dist'          => { COMPRESS   => 'gzip -9',
                         SUFFIX     => '.gz',
                         DIST_DEFAULT   => 'all tardist',
                       },
);
