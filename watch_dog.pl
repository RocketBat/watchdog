#!/usr/bin/perl

#-----------|
# Build 126 |
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
use threads;
use Parallel::ForkManager;

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
use scripts::restart;
use scripts::bypass_on;
use scripts::bypass_off;

#--prototypes
sub watch_dog;
sub status;
sub textout;

#--variable
my $logthread;

#--main logic of script
my $logProc = Parallel::ForkManager->new(1); #max 1 child process
bypass_state();
while (1) {
    $date = strftime "%F", localtime;
    $log_file = $directory.$date.'-master-out.log';
    while (1){
		$datestring = strftime "%F %T", localtime;
		(my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();
		if ($hour==3 && $min==0 && $sec <= 5) {last;}
		print"Debug message\n";
		if (status()==0) {
			my $thr1 = threads->create(\&bypass_out_status_ok);
			$thr1->join();
		}
		else {
			my $thr2 = threads->create(\&bypass_out_status_bad);
			$thr2->join();
		}
		$logthread = threads->start and textout(5);
	}
	$logthread->finish;
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
		my ($sleep) = @_;
		print "$datestring $textmsg_zcheck \n";
		print "$datestring $textmsg_proc \n";
		print "$datestring $textmsg_fresh \n";
		print "$datestring $textmsg_cdrops drop $drop_rate1 and $drop_rate2\n";
		sleep $sleep; #tak nado
}
