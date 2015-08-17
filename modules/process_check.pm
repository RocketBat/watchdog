package modules::process_check;

=pod
This module checking process for dpi
=cut

use strict;
use warnings;
use Exporter;

use lib '/home/mihail/Develop/watch_dog/scripts';
use scripts::start;
use lib '/home/mihail/Develop/watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(process_check);
}

#check dpi process 
sub process_check {
    my $check;
    my $process_status = `ps afx | grep "bin/dpi-engine" | grep -v grep`;
    if ($process_status eq ""){
        $check=1;
		$textmsg_proc = ' Did not find DPI process in process list';
		$logmsg = ' bypass on, Did not find DPI process in process list';
        start();
    }
    else{
        $check=0;
        $textmsg_proc=' Found DPI process in process list.';
        $logmsg = ' Found DPI process in process list';
    }
    return $check;
}

1;