package modules::logging;

=pod
This module setup output information
=cut

use strict;
use warnings;
use Exporter;

#--my libraries
use lib '/home/mihail/Develop/watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(setloginfo setTextRestartDPI setTextStartDPI textout outlog setSavestate_bypass);
}

#sub textout {
	#if (time() - $logtime_delay == $refresh_timer || $logtime_delay == 0) {
		#print "$datestring $textmsg_proc \n";
		#print "$datestring $textmsg_zcheck \n";
		#print "$datestring $textmsg_fresh \n";
		#print "$datestring $textmsg_cdrops drop $drop_rate1 and $drop_rate2\n";
	#}
#}

#sub outlog {
#	if (time() - $logtime_delay == $refresh_timer || $logtime_delay == 0) {
#		system("echo $datestring $logmsg_proc >>  $watchdog_log");
#		system("echo $datestring $logmsg_zcheck >>  $watchdog_log");
#		system("echo $datestring $logmsg_fresh >>  $watchdog_log");
	#	system("echo $datestring $logmsg_cdrops ' drop ' $drop_rate1 ' and ' $drop_rate2 >>  $watchdog_log");
	#}
#}

sub setSavestate_bypass {
	print "$datestring save system state, because bypass is recently ON\n";
	system("echo $datestring ' save system state, because bypass is recently ON' >> $watchdog_log");	
	sleep 5;
}

sub setTextStartDPI {
		print "$datestring DPI process not found. Starting DPI-Engine.\n";
   		system("echo $datestring 'DPI process not found. Starting DPI-Engine.' >> $watchdog_log");
		sleep 5;
}

sub setTextRestartDPI {
	print "$datestring Restarting DPI-Engine.\n";
	system("echo $datestring 'Zombie found. Restarting DPI-Engine.' >> $watchdog_log");
    sleep 5;
}

sub setloginfo {
	my ($module_type) = @_;
	if ($module_type eq "zombie") {
		system("echo $datestring $logmsg >>  $watchdog_log");
	}
	elsif ($module_type eq "proc_check") {
		system("echo $datestring $logmsg >>  $watchdog_log");
	}
	elsif ($module_type eq "fresh") { #file refresh
		system("echo $datestring $logmsg >>  $watchdog_log");
	}
	elsif ($module_type eq "chk_drop") {
		system("echo $datestring $logmsg $drop_rate1 ' and ' $drop_rate2>>  $watchdog_log");
	}
	elsif ($module_type eq "readn_drop") {
		system("echo $datestring $logmsg >>  $watchdog_log");
	}	
}

1;