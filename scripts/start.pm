package scripts::start;

=pod
This module starting DPI
=cut

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
    our @EXPORT      = qw(start);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

sub start {
	$CWD = '/usr/adm/adm_s1';
    system('./start');
    print "$datestring DPI process not found. Starting DPI-Engine.\n";
    system("echo $datestring 'DPI process not found. Starting DPI-Engine.' >> $watchdog_log");
}

1;