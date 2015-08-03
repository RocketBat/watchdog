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

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION     = 1.7.0;
    # Inherit from Exporter to export functions and variables
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(bypass_out_status_bad);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
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
			#`bpctl_util all set_bypass on`;#	                 |
			system("echo 'bypasssishe vklycheno'");
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
		$bypass=1;
		if ($text_out==$refresh_timer) {
			system("echo 'Save system state'");
			$text_out=0;
		}
		else {$text_out++;}
	}
}

1;