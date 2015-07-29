package modules::zombie_check;

=pod
This module checking DPI process about zombie
=cut

############
# Build 1  #
############

use strict;
use warnings;
use Exporter;

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/configs';
use configs::main;
use lib '/home/mihail/Develop/Watch_dog/scripts';
use scripts::start;
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

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
    our @EXPORT      = qw(zombie_check);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

sub zombie_check {
	my $check;
	my $zombie_ck = `ps afx | grep "dpi-engine" | grep defunct | grep -v grep`;
	if ($zombie_ck eq "") {
		$check=0;
		$textmsg_zcheck=' No zombie processes.';
	}
	else {
		$check=1;
		$textmsg_zcheck=' Achtung! Found ZOMBIE!';
		if ($text_out==$refresh_timer) {
			system("echo $datestring 'Achtung! Found ZOMBIE in process list!' >> $watchdog_log");
			$logger->info("Achtung! Found ZOMBIE in process list!");
		}
	}
	return $check;
}

1;