package modules::stuck_check;

=pod
This module checking that Fastlink is forwarded traffic to dpi
=cut

use strict;
use warnings;
use Exporter;

use lib '/usr/adm/watchdog/lib/common';
use common::variables;
use lib '/usr/adm/watchdog/lib/scripts';
use scripts::bypass_on;
use scripts::bypass_off;
use lib '/usr/adm/watchdog/lib/modules';
use modules::logging;
use modules::mail_send;
use modules::bypass_state;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(getStuckRes stuck_check);
}

my $count = 0; #needs for counting speed 
my $count_timer = 0;
my $stuckTime = 0; #use for counting one second for stuck check
my $check;

#func that counting time when there is not traffic in system 
sub stuck_count {
    $stuckTime = time() - $count_timer;
    # 120 second delay before bypass is going ON
    if ($mspeed1 <= 20 && $mspeed2 <= 20 && $stuckTime >= 1 && $bypass == 0) {
        if (time() - $count_timer <= 20) { #120 sec means 2 min
            $count++;
            print "Traffic count ++ does not return!\n"; #debug infoermatinon
        }
        else {
            $count = 0;
            print "Traffic does not return set by zer0 !\n"; #debug infoermatinon
        }
        $count_timer = time();
    }
}

#func see is there traffic in system
sub stuck_func {
    $mspeed1 = $1;
	$mspeed2 = $2;
    stuck_count();
	if ($mspeed1 <= 20 && $mspeed2 <= 20 && $count == 20 && $bypass == 0) {
		$check = 1;
        $logmsg = ' Traffic does not return to dpi. Starting bypass for 2 min.';
		print "Traffic does not return!\n"; #debug infoermatinon 
    }
    else {
        $check = 0;
    }
    return $check;
}


#check that traffic is go to dpi (in fastlink)
sub stuck_check {
    my $line = `tail -n 28 $log_file | grep "iMbits_ps"`;
    if ($shaper_type eq 'twin' && $line =~ m/iMbits_ps\s+(\d.*)\s+(\d.*)\s+(\d.*)\s/) { 
    	stuck_func();
    }
    if ($shaper_type eq 'one' && $line =~ m/iMbits_ps\s+(\d.*)\s+(\d.*)\s/) { 
    	stuck_func();
    }
    return $check;
}

# get information about speed and if speed less than 20 Mbps starting bypass
sub getStuckRes {
	if (stuck_check()==1) {
		$stat="There is not traffic in DPI. Turn on bypass for 2 min!";
		if ($revision eq "debug") {
			system("echo 'Bypasss is onnnN!'");
			system("echo $datestring 'Bypass turn on'");
		}
		elsif ($revision eq "release") {
			############REMEMBER: add the real function of bypass|
			`bpctl_util all set_bypass on`;#	                 |
			#####################################################|
		}
		else {
			print "Wrong parameter revison in config\n";
		}
		send_mail("$server bypass status is ON ","$datestring $stat");
        setloginfo("stuck");
		sleep 20; #2 minutes
	}
}

1;