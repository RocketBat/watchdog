package modules::logging;

=pod
This module setup output information
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
    our @EXPORT      = qw(setTextRestartDPI setTextStartDPI textout outlog setSavestate setSavestate_bypass);
}

sub textout {
	if (time() - $logtime_delay == $refresh_timer || $logtime_delay == 0) {
		$logtime_delay = time();
		print "$datestring $textmsg_proc \n";
		print "$datestring $textmsg_zcheck \n";
		print "$datestring $textmsg_fresh \n";
		print "$datestring $textmsg_cdrops drop $drop_rate1 and $drop_rate2\n";
	}
}

#sub outlog {
#	if (time() - $logtime_delay == $refresh_timer || $logtime_delay == 0) {
#		system("echo $datestring $logmsg_proc >>  $watchdog_log");
#		system("echo $datestring $logmsg_zcheck >>  $watchdog_log");
#		system("echo $datestring $logmsg_fresh >>  $watchdog_log");
	#	system("echo $datestring $logmsg_cdrops ' drop ' $drop_rate1 ' and ' $drop_rate2 >>  $watchdog_log");
	#}
#}

sub setSavestate_bypass {
	if (time() - $logtime_delay == $refresh_timer || $logtime_delay == 0) {
		print "$datestring save system state, because bypass is recently ON\n";
		system("echo $datestring ' save system state, because bypass is recently ON' >> $watchdog_log");	
	}
}

sub setSavestate {
	if (time() - $logtime_delay == $refresh_timer || $logtime_delay == 0) {
		system("echo 'Save system state'");
	}
}

sub setTextStartDPI {
	if (time() - $logtime_delay == $refresh_timer || $logtime_delay == 0) {
		print "$datestring DPI process not found. Starting DPI-Engine.\n";
   		system("echo $datestring 'DPI process not found. Starting DPI-Engine.' >> $watchdog_log");
    }
}

sub setTextRestartDPI {
	if (time() - $logtime_delay == $refresh_timer || $logtime_delay == 0) {
		print "$datestring Restarting DPI-Engine.\n";
	    system("echo $datestring 'Zombie found. Restarting DPI-Engine.' >> $watchdog_log");
    }
}

1;