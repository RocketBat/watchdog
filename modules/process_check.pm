package modules::process_check;

=pod
This module checking process for dpi
=cut

use strict;
use warnings;
use Exporter;

use lib '/home/mihail/Develop/Watch_dog/scripts';
use scripts::start;
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(process_check);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

sub process_check {
    my $check;
    my $process_status = `ps afx | grep "bin/dpi-engine" | grep -v grep`;
    if ($process_status eq ""){
        $check=1;
		$textmsg_proc = ' Did not find DPI process in process list';
        $logmsg_proc = ' bypass on, Did not find DPI process in process list';
		start();
    }
    else{
        $check=0;
        $textmsg_proc=' Found DPI process in process list.';
        $logmsg_proc = ' Found DPI process in process list';
    }
    return $check;
}

1;