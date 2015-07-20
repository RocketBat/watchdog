package configs::main;

=pod
This module setup the ervision of watchdog
=cut

############
# Build 2  #
############

use strict;
use warnings;
use Exporter;

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION     = 1.0.0;
    # Inherit from Exporter to export functions and variables
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(revision_check $revision);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

our $revision = 'debug';

sub revision_check {
    if ($revision eq "debug") {
        print "This is debug version\n";
    }
    elsif ($revision eq "release") {
        print "This is release version\n";
    }
    else {
        print "Variable /$revision is wrong\n";
    }
}

1;
