package modules::logging;

=pod
This module setup output information
=cut

use strict;
use warnings;
use Exporter;

#--my libraries
use lib '/usr/adm/watchdog/lib/common';
use common::variables;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(setloginfo setTextRestartDPI setTextStartDPI textout outlog setSavestate_bypass);
}

sub setSavestate_bypass {
	system("echo $datestring ' save system state, because bypass is recently ON' >> $watchdog_log");	
	sleep 5;
}

sub setTextStartDPI {
		system("echo $datestring 'DPI process not found. Starting DPI-Engine.' >> $watchdog_log");
		sleep 5;
}

sub setTextRestartDPI {
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
	elsif ($module_type eq "stuck") {
		system("echo $datestring $logmsg >>  $watchdog_log");
	}	
}

1;