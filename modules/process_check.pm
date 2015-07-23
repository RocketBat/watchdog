package modules::process_check;

=pod
This module checking process for dpi
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
    our @EXPORT      = qw();
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

sub process_check {
    my $check;
    my $process_status = `ps afx | grep "dpi-engine" | grep -v grep`;
    if ($process_status eq ""){
        $check=1;
		$textmsg_proc = ' Did not find DPI process in process list';
		if ($text_out==$refresh_timer) {
			system("echo $datestring 'bypass on, Did not find DPI process in process list' >> $watchdog_log");
			$logger->info("$datestring bypass on, Did not find DPI process in process list");
		}
		start();
    }
    else{
        $check=0;
        $textmsg_proc=' Found DPI process in process list.';
    }
    return $check;
}

1;