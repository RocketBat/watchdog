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
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(start);
}

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

sub start {
	$CWD = '/usr/adm/adm_s1';
    system('./start');
    if ($text_out==$refresh_timer) {
        print "$datestring DPI process not found. Starting DPI-Engine.\n";
        system("echo $datestring 'DPI process not found. Starting DPI-Engine.' >> $watchdog_log");
    }
}

1;