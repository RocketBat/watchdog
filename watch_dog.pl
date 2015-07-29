#!/usr/bin/perl

#-----------|
# Build 115 |
#-----------|

#------SERVER NAME------|
#my $server = 'Mighty';#|
#-----------------------|

#--includes
use POSIX qw(strftime);
use strict;
use warnings;
use File::stat;
use File::chdir;
use Exporter;
use Log::Log4perl;

#--initialise logging config
Log::Log4perl::init('/home/mihail/Develop/Watch_dog/configs/log.conf');
my $logger = Log::Log4perl->get_logger("wd_debug");

#--include my libraries
use modules::bypass_state;
use modules::mail_send;
use modules::process_check;
use modules::filerefresh;
use common::variables;
use modules::check_drops;
use modules::zombie_check;
use common::bypass_loop;
use scripts::restart;

#---Prototypes
#sub bypass_loop;
#sub send_mail;
sub process_check;
sub filerefresh;
sub check_drops;
sub zombie_check;
sub start;
sub restart;
sub watch_dog;
sub status;
sub textout;
sub bypass_out_status_ok;
sub bypass_out_status_bad;
sub bypass_check;
sub bypass_state;

#--main logic of script
bypass_state();
while (1) {
    $date = strftime "%F", localtime;
    $log_file = $directory.$date.'-master-out.log';
    while (1){
		$datestring = strftime "%F %T", localtime;
		(my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();
		if ($hour==3 && $min==0 && $sec <= 5) {last;}
		if (status()==0) {
			textout();
			bypass_out_status_ok();
		}
		else {
			textout();
			bypass_out_status_bad();
		}
	}
}

#--------big function (main function of this script)
sub watch_dog {
	if (zombie_check()==1) {restart(); return 1; }
	if (process_check()==1)	{return 2;}
	if (filerefresh()==1) {return 3;}
	if (check_drops()==1) {return 4;}
    return 0;
}

#----error status
sub status {
	my $wd_status=watch_dog();
	if ($wd_status==0) {return 0;}
	elsif ($wd_status==1) {$stat="Achtung! Zombi process detected!"; }
	elsif ($wd_status==2) {$stat="Achtung! DPI-process not found!";}
	elsif ($wd_status==3) {$stat="Achtung! Log file does not updating!";}
	elsif ($wd_status==4) {$stat="Achtung! Drops very high!";}
	return 1;
}

#---text out function
sub textout {
	if ($text_out==$refresh_timer) {
		print "$datestring $textmsg_zcheck \n";
		print "$datestring $textmsg_proc \n";
		print "$datestring $textmsg_fresh \n";
		print "$datestring $textmsg_cdrops drop $drop_rate1 and $drop_rate2\n";
	}
}

#--function when all is GOOD
sub bypass_out_status_ok {
	if ($bypass == 0) {
		$bypass=0;
		if ($text_out==$refresh_timer) {
			system("echo $datestring 'Save system state'");
			$text_out=0;
		}
		else {$text_out++;}
	}
	else {
		bypass_check();
	}
}

#--function when needs to be bypass in ON
sub bypass_out_status_bad {
	if ($bypass == 0) {
		$bypass=1;
		$bypass_on_time=time();
		############REMEMBER: add the real function of bypass|
		system("echo 'Bypasss is onnnN!'");#                 |
		#####################################################|
		send_mail("$server bypass status is ON","$datestring $stat");
		system("echo $datestring 'Bypass turn on'");
		system("echo $datestring 'Bypass turn on' >> $watchdog_log");
		$logger->info("Bypass turn on");
		bypass_loop();
	}
	else {
		$bypass=1;
		if ($text_out==$refresh_timer) {
			system("echo 'Save system state'");
			$text_out=0;
		}
		else {$text_out++;}
	}
}

sub bypass_check {
	$bypass_off_time=time();
	if ($bypass_off_time - $bypass_on_time <= $delay_removal_from_bypass) {
		if ($text_out == $refresh_timer) {
			print "$datestring save system state, because bypass is recently ON\n";
			system("echo $datestring ' save system state, because bypass is recently ON' >> $watchdog_log");
			$logger->info("save system state, because bypass is recently ON");
			$text_out = 0;
		}
		else {$text_out++;}
	}
	else {
		$bypass=0;
		############REMEMBER: add the real function of bypass|
		system("echo 'Bypasss is oFFFFFFFFuuuuu'");#         |
		#####################################################|
		send_mail("$server bypass status is OFF","$datestring Bypass is off");
		system("echo $datestring 'Bypass turn off'");
		system("echo $datestring 'Bypass turn off' >> $watchdog_log");
		$logger->info("Bypass turn off");
	}
}
