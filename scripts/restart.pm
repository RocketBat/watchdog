package scripts::restart;

=pod
This module restarting DPI
=cut

############
# Build 1  #
############

use strict;
use warnings;
use Exporter;
use File::chdir;

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION     = 1.0.0;
    # Inherit from Exporter to export functions and variables
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(restart);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

#--initialise logging config
Log::Log4perl::init('/home/mihail/Develop/Watch_dog/configs/log.conf');
my $logger = Log::Log4perl->get_logger("wd_info");

sub restart {
	$CWD = '/usr/adm/adm_s1';
	system('./stop');
	system('./start');	
	print "$datestring Restarting DPI-Engine.\n";
	system("echo $datestring 'Zombie found. Restarting DPI-Engine.' >> $watchdog_log");
	$logger->info("Zombie found. Restarting DPI-Engine.");
}

1;