package scripts::bypass_on;

=pod
This module set bypass to ON state
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
    our @EXPORT      = qw(bypass_out_status_bad);
}

sub bypass_out_status_bad {
	if ($bypass == 0) {
		$bypass=1;
		$bypass_on_time=time();
		if ($revision eq "debug") {
			############REMEMBER: add the real function of bypass|
			system("echo 'Bypasss is onnnN!'");#                 |
			#####################################################|
		}
		elsif ($revision eq "release") {
			############REMEMBER: add the real function of bypass|
			`bpctl_util all set_bypass on`;#	                 |
			#####################################################|
		}
		else {
			print "Wrong parameter revison in config\n";
		}
		send_mail("$server bypass status is ON","$datestring $stat");
		system("echo $datestring 'Bypass turn on'");
		system("echo $datestring 'Bypass turn on' >> $watchdog_log");
		bypass_loop();
	}
	else {
		setSavestate();
	}
}

1;