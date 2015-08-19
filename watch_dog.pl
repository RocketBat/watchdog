#!/usr/bin/perl

#-----------|
# Build 161 |
#-----------|

#---------SERVER NAME------|
#        'Generator'       |
#--------------------------|

#--includes
use POSIX qw(strftime);
use strict;
use warnings;
use File::stat;
use File::chdir;
use Exporter;
use IO::Handle;
use MCE;

#--include my libraries
use modules::bypass_state;
use modules::mail_send;
use modules::process_check;
use modules::filerefresh;
use common::variables;
use modules::check_drops;
use modules::zombie_check;
use scripts::restart;
use scripts::bypass_on;
use scripts::bypass_off;
use modules::logging;
use modules::wdlogstatus;

my $mce = MCE->new(
	user_func => sub {
		while (1) {
    		$date = strftime "%F", localtime;
			if ($shaper_type eq "twin") {
    			$log_file = $directory.$date.'-master-out.log';
    		}
			elsif ($shaper_type eq "one") {
				$log_file = $directory.$date.'-out.log';
			}
			while (1) {
				$datestring = strftime "%F %T", localtime;
				(my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();
				if ($hour==3 && $min==0 && $sec <= 5) {last;}
				if (watch_dog()==0) {
					bypass_out_status_ok();
				}
				else {
					bypass_out_status_bad();
					sleep 5;
				}
			}
		}
	}
);

#--main logic of script
bypass_state();
$mce->run;
