package modules::bypass_state;

=pod
This module checks the status of the bypass
during the initial initialization script.
=cut

############
# Build 6  #
############

use strict;
use warnings;
use Exporter;

#--my libraries
#use lib '/home/mihail/Develop/Watch_dog/configs';
#use configs::main;
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION     = 1.7.0;
    # Inherit from Exporter to export functions and variables
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(bypass_state $bypass);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

our $bypass;

sub bypass_state {
    if ($revision eq "debug") {
        if (`cat get_bypass | grep on | grep -v grep` eq "") {
            $bypass=0;
            print "bypass is off\n";
        }
        else {
            $bypass=1;
            print "bypass is on\n";
        }
    }
    elsif ($revision eq "release") {
        if (`cat get_bypass | grep on | grep -v grep` eq "") {   #<--- CHECK THIS
		$bypass=0;
		print "Bypass is off\n";
	}
	else {
		$bypass=1;
		print "Bypass is on\n";
	}
    }
}

1;
