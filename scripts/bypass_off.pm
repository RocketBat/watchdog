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
use modules::logging;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(bypass_out_status_ok);
}
#--prototype
sub bypass_check;

#--function that set bypass off
sub bypass_out_status_ok {
	if ($bypass == 0) {
		$bypass=0;
		setSavestate();
	}
	else {
		bypass_check();
	}
}


#this function check system for previous bypass state
sub bypass_check {
	$bypass_off_time=time();
	if ($bypass_off_time - $bypass_on_time <= $delay_removal_from_bypass) {
		setSavestate_bypass();
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