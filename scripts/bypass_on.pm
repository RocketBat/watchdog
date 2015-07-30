package scripts::bypass_on;

=pod
This module set bypass to ON state
=cut

############
# Build 4  #
############

use strict;
use warnings;
use Exporter;

#--my libraries
#use lib '/home/mihail/Develop/Watch_dog/configs';
#use configs::main;
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;
use common::bypass_loop;
use lib '/home/mihail/Develop/Watch_dog/modules';
use modules::bypass_state;
use modules::mail_send;

#--initialise logging config
Log::Log4perl::init('/home/mihail/Develop/Watch_dog/configs/log.conf');
my $logger = Log::Log4perl->get_logger("wd_info");

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
		############REMEMBER: add the real function of bypass|
		system("echo 'Bypasss is onnnN!'");#                 |
		#####################################################|
		send_mail("$server bypass status is ON","$datestring $stat");
		system("echo $datestring 'Bypass turn on'");
		system("echo $datestring 'Bypass turn on' >> $watchdog_log");
		$logger->info("Bypass turn on");
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