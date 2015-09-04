package scripts::restart;

=pod
This module restarting DPI
=cut

use strict;
use warnings;
use Exporter;
use File::chdir;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(restart);
}

#--my libraries
use lib '/usr/adm/watchdog/lib/common';
use common::variables;
use lib '/usr/adm/watchdog/lib/modules';
use modules::logging;

sub restart {
	$CWD = '/usr/adm/adm_s1';
	system('./stop');
	system('./start');
    setTextRestartDPI();
}

1;