package modules::wdlogstatus;

=pod
This module set log info
=cut

use strict;
use warnings;
use Exporter;

use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;
use lib '/home/mihail/Develop/Watch_dog/modules';
use modules::logging;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(watch_dog);
}

#--------big function (main function of this script)
sub watch_dog {
	if (zombie_check()==1) {
		restart();  
		$stat="Achtung! Zombi process detected!";
        setloginfo("zombie");
		return 1;
	}
	if (process_check()==1)	{
		$stat="Achtung! DPI-process not found!";
        setloginfo("proc_check");
		return 2;
	}
	if (filerefresh()==1) {
		$stat="Achtung! Log file does not updating!";
        setloginfo("fresh");
		return 3;
	}
	if (check_drops()==1) {
		$stat="Achtung! Drops very high!";
        setloginfo("chk_drop");
        return 4;
	}
	if (check_drops()==2) {
		$stat="Achtung! Can not read drop rate!";
        setloginfo("readn_drop");
		return 5;
	}
    return 0;
}


1;