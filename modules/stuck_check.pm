package modules::stuck_check;

=pod
This module checking that Fastlink is forwarded traffic to dpi
=cut

use strict;
use warnings;
use Exporter;

use lib '/home/mihail/Develop/watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(stuck_check);
}

#check that traffic is go to dpi (in fastlink)
sub stuck_check {
	my $line = `tail -n 28 $log_file | grep "iMbits_ps"`;
    if ($line =~ m/iMbits_ps\s+(\d.*)\s+(\d.*)\s/){ 
    	$mspeed1 = $1;
		$mspeed2 = $2;
		if ($mspeed1 <= 1) {
			
		}
}


1;