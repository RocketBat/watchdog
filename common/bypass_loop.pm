package common::bypass_loop;

=pod
This module prevents bypass looping
=cut

use POSIX qw(strftime);
use strict;
use warnings;
use Exporter;

#--our libraries
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION     = 1.0.0;
    # Inherit from Exporter to export functions and variables
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(bypass_loop);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

sub bypass_loop {
	my $t = time();
	if ($t1 && $t-$t1 < 180) {
		print "$datestring Achtung! Bypass is on 3 times per 3 min! Enabling static bypass by 1 hour!\n";
		system("echo $datestring 'Achtung! Bypass is on 3 times per 3 min! Enabling static bypass by 1 hour! ' >> $watchdog_log");
		if ($revision eq "debug") {
			###########Bypass#ON##################
			system("echo 'Vkl bypass na chas'"); #
			######################################
		}
		elsif ($revision eq "release") {
			###########Bypass#ON##################
			system("echo 'bypasssishe vklycheno'"); #
			#`bpctl_util all set_bypass on`;
			######################################
		}
		else {
			print "Wrong parameter revison in config\n";
		}	
		send_mail("$server bypass status is permanently ON ","$datestring Bypass is ON by 1 hour!");
		sleep 3600;
	}
	$t1 = $t2;
	$t2 = $t;
}

1;