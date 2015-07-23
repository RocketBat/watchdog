package scripts::start;

=pod
This module starting DPI
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
    our @EXPORT      = qw();
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

#--initialise logging config
Log::Log4perl::init('/home/mihail/Develop/Watch_dog/configs/log.conf');
my $logger = Log::Log4perl->get_logger("wd_info");

sub start {
	$CWD = '/usr/adm/adm_s1';
    system('./start');
    print "$datestring DPI process not found. Starting DPI-Engine.\n";
    system("echo $datestring 'DPI process not found. Starting DPI-Engine.' >> $watchdog_log");
	$logger->info("DPI process not found. Starting DPI-Engine.");
}

1;