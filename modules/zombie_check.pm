package modules::zombie_check;

=pod
This module checking DPI process about zombie
=cut

use strict;
use warnings;
use Exporter;

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(zombie_check);
}

#check dpi process for zombie status
sub zombie_check {
	my $check;
	my $zombie_ck = `ps afx | grep "dpi-engine" | grep defunct | grep -v grep`;
	if ($zombie_ck eq "") {
		$check=0;
		$textmsg_zcheck = ' No zombie processes.';
		$logmsg = ' No zombie processes';
	}
	else {
		$check=1;
		$textmsg_zcheck=' Achtung! Found ZOMBIE!';
		$logmsg = ' No zombie processes';
	}
	return $check;
}

1;