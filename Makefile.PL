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

# Can't use this because versions of MakeMaker < 5.45 'use' the module
# instead of 'require'ing and this causes Test::Simple to bitch.
#    PREREQ_PM       => { Test::Simple => 0.04  },
my %write_makefile = (    
    NAME            => $PACKAGE,
    VERSION_FROM    => "lib/$PACKAGE_FILE.pm", # finds $VERSION
    'dist'          => { COMPRESS   => 'gzip -9',
                         SUFFIX     => '.gz',
                         DIST_DEFAULT   => 'all tardist',
                       },
);

if( $ExtUtils::MakeMaker::VERSION < 5.45 ) {
    if( !eval { require Test::Simple; 1 } ) {
        warn "Test::Simple version >= 0.05 required but not found\n";
    }
    elsif( (my $version = $Test::Simple::VERSION) < 0.05 ) {
        warn "Test::Simple version >= 0.05 requires but $version found\n";
    }
}
else {
    $write_makefile{PREREQ_PM} = { Test::Simple => 0.05 };
}


WriteMakefile(%write_makefile);
