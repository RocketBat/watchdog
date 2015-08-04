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
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

sub restart {
	$CWD = '/usr/adm/adm_s1';
	system('./stop');
	system('./start');
    if ($text_out==$refresh_timer) {	
	   print "$datestring Restarting DPI-Engine.\n";
	   system("echo $datestring 'Zombie found. Restarting DPI-Engine.' >> $watchdog_log");
    }
}

1;