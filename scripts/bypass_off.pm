package scripts::bypass_off;

=pod
This module set bypass to OFF state
=cut

use strict;
use warnings;
use Exporter;

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;
use common::bypass_loop;
use lib '/home/mihail/Develop/Watch_dog/modules';
use modules::bypass_state;
use modules::mail_send;

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION     = 1.7.0;
    # Inherit from Exporter to export functions and variables
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(bypass_out_status_ok);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}
#--prototype
sub bypass_check;

#--function that set bypass off
sub bypass_out_status_ok {
	if ($bypass == 0) {
		$bypass=0;
		if ($text_out==$refresh_timer) {
			system("echo $datestring 'Save system state'");
			$text_out=0;
		}
		else {$text_out++;}
	}
	else {
		bypass_check();
	}
}

sub bypass_check {
	$bypass_off_time=time();
	if ($bypass_off_time - $bypass_on_time <= $delay_removal_from_bypass) {
		if ($text_out == $refresh_timer) {
			print "$datestring save system state, because bypass is recently ON\n";
			system("echo $datestring ' save system state, because bypass is recently ON' >> $watchdog_log");
			$text_out = 0;
		}
		else {$text_out++;}
	}
	else {
		$bypass=0;
		if ($revision eq "debug") {
			############REMEMBER: add the real function of bypass|
			system("echo 'Bypasss is oFFFFFFFFuuuuu'");#         |
			#####################################################|
		}
		elsif ($revision eq "release")  {
			############REMEMBER: add the real function of bypass|
			`bpctl_util all set_bypass off`;#        			 |
			#####################################################|
		}
		else {
			print "Wrong parameter revison in config\n";
		}
		send_mail("$server bypass status is OFF","$datestring Bypass is off");
		system("echo $datestring 'Bypass turn off'");
		system("echo $datestring 'Bypass turn off' >> $watchdog_log");
	}
}

1;