#!/usr/bin/perl

#-----------|
# Build 152 |
#-----------|

#------SERVER NAME------|
#        'Mighty'       |
#-----------------------|

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

sub watch_dog;

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
				$logtime_delay = time();
				textout();
				bypass_out_status_ok();
			}
			else {
				$logtime_delay = time();
				textout();
				outlog();
				bypass_out_status_bad();
			}
		}
	}
	}
);

#--main logic of script
bypass_state();
$mce->run;

#--------big function (main function of this script)
sub watch_dog {
	if (zombie_check()==1) {
		restart();  
		$stat="Achtung! Zombi process detected!";
		system("echo $datestring $logmsg >>  $watchdog_log");
		return 1;
	}
	if (process_check()==1)	{
		$stat="Achtung! DPI-process not found!";
		system("echo $datestring $logmsg >>  $watchdog_log");
		return 2;
	}
	if (filerefresh()==1) {
		$stat="Achtung! Log file does not updating!";
		system("echo $datestring $logmsg >>  $watchdog_log");
		return 3;
	}
	if (check_drops()==1) {
		$stat="Achtung! Drops very high!";
		system("echo $datestring $logmsg $drop_rate1 ' and ' $drop_rate2>>  $watchdog_log");
		return 4;
	}
	if (check_drops()==2) {
		$stat="Achtung! Can not read drop rate!";
		system("echo $datestring $logmsg >>  $watchdog_log");
		return 5;
	}
    return 0;
}
