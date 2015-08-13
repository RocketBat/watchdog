package modules::bypass_state;

=pod
This module checks the status of the bypass
during the initial initialization script.
=cut

use strict;
use warnings;
use Exporter;

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(bypass_state $bypass);
}

our $bypass;

#read bypass state from network module
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
        if (`bpctl_util all get_bypass | grep on | grep -v grep` eq "") {
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
