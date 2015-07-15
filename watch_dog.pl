#!/usr/bin/perl

#----------|
# Build 88 |
#----------|

#-----SERVER NAME------|
my $server = 'Mighty';#|
#----------------------|

#--includes
use POSIX qw(strftime);
use strict;
use warnings;
use File::stat;
use File::chdir;

#---variables
my $bypass; #--0-off--|--1-on--
my $max_drops = 0.04;
my $datestring = strftime "%F %T", localtime;
my $directory = '/usr/adm/adm_s1/logs/';
my $date = strftime "%F", localtime;
my $log_file;
my $t1 = 0;
my $t2 = 0;
my $stat; #---need for mailing status
my $refresh_timer = 80; #----speed of logging
my $textmsg_proc; #---text message processcheck
my $textmsg_fresh; #---text message filerefresh
my $textmsg_cdrops = ' Can not read drop rate!'; #---text message checkdrops
my $textmsg_zcheck; #---text message zombie
my $logmsg_proc; #---log message processcheck
my $logmsg_fresh; #---log message filerefresh
my $logmsg_cdrops; #---log message checkdrops
my $logmsg_zcheck; #---log message zombie
my $text_out = 0; #---need for text output
my $drop_rate1 = 0; #--drops upload
my $drop_rate2 = 0; #--drops download
my $bypass_on_time = 0; # last time when bypass is on
my $bypass_off_time = 0; # last time when bypass is off
my $watchdog_log = '/home/mihail/Develop/Watch_dog/bypass.log'; #---CHECK FULL PATH
my $relay_for_text = 1;

#---Prototypes
sub bypass_loop;
sub send_mail;
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
    $log_file = $directory.$date.'-out.log';
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
		$relay_for_text = 1;
	}
}

#---------detecting bypass state
sub bypass_state {
	if (`cat get_bypass | grep on | grep -v grep` eq "") {   #<--- CHECK THIS
		$bypass=0;
		print "bypass is off\n";
	}
	else {
		$bypass=1;
		print "bypass is on\n";
	}
}

#-----function that checking bypass loop (must be commented if version for Fastlink)
sub bypass_loop {
	my $t = time();
	if ($t1 && $t-$t1 < 180) {
		print "$datestring Achtung! Bypass is on 3 times per 3 min! Enabling static bypass by 1 hour!\n";
		system("echo $datestring 'Achtung! Bypass is on 3 times per 3 min! Enabling static bypass by 1 hour! ' >> $watchdog_log"); #<--- CHECK THIS
		system("echo 'Vkl bypass na chas'"); #----------------------REMEMBER: add the real function of bypass
		send_mail("$server bypass status is permanently ON ","$datestring Bypass is ON by 1 hour!"); #<--- CHECK THIS
		sleep 3600;
	}
	$t1 = $t2;
	$t2 = $t;
}

#----function sending email
sub send_mail { #<--- CHECK THIS
	my ($subject, $message) = (@_);
	my $from = 'mikhail.kozlov@adm-systems.com';
	my $to = 'mikhail.kozlov@adm-systems.com';
	open(MAIL, "|/usr/sbin/sendmail -t");
	# Email Header
	print MAIL "To: $to\n";
	print MAIL "From: $from\n";
	print MAIL "Content-type: text/html\n";
	print MAIL "Cc: Coffe-man\@mail.ru\n";
#	print MAIL "Cc: some-mail@site\n";
	print MAIL "Subject: $subject\n\n";
	
	# Email Body
	print MAIL $message;
	close(MAIL);
	print "Email Sent Successfully\n";
}

#-----------function check process
sub process_check {
    my $check;
    my $process_status = `ps afx | grep "dpi-engine" | grep -v grep`;
    if ($process_status eq ""){
        $check=1;
		$textmsg_proc = ' Did not find DPI process in process list';
		if ($text_out==$refresh_timer && $relay_for_text == 1) {
			system("echo $datestring 'bypass on, Did not find DPI process in process list' >> $watchdog_log");
			$relay_for_text = 0;
		}
		start();
    }
    else{
        $check=0;
        $textmsg_proc=' Found DPI process in process list.';
    }
    return $check;
}


#-------------function filerefresh
sub filerefresh {
    my $obnovlenie;
    my $mt = stat($log_file);
    my $st = $mt -> mtime;
    if ($st +1 >= time()) {
        $textmsg_fresh=' Log file updating ';
        $obnovlenie=0;
    }
    else {
        $obnovlenie=1;
        $textmsg_fresh = ' Achtung! Log does not updating!';
		if ($text_out==$refresh_timer && $relay_for_text == 1) {
			system("echo $datestring 'bypass on, Log does not updating!' >> $watchdog_log");
			$relay_for_text = 0;
		}
	}
    return $obnovlenie;
}

#------------function check drops
sub check_drops {
    my $check;
    my $line = `tail -n 28 $log_file | grep "dropRate this moment"`;
    if ($line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)/){
        $drop_rate1 = $1;
        $drop_rate2 = $2;
       	if($drop_rate1 > $max_drops || $drop_rate2 > $max_drops){
        	$check=1;
            $textmsg_cdrops = ' Drops level exceeds the configured maximum of $max_drops';
			if ($text_out==$refresh_timer && $relay_for_text == 1) {
				system("echo $datestring 'bypass is on, droprate is = $drop_rate1 and $drop_rate2' >> $watchdog_log");
				$relay_for_text = 0;
			}
        }
       	else{
            $check=0;
            $textmsg_cdrops=' Drops level is in normal range';
		}
    }
    else{
        $check=1;
		$textmsg_cdrops = ' Can not read drop rate';
		if ($text_out==$refresh_timer && $relay_for_text == 1) {
			system("echo $datestring 'bypass is on, Can not read drop rate!' >> $watchdog_log");
			$relay_for_text = 0;
		}
	}
	return ($drop_rate1, $drop_rate2, $max_drops, $check);
}

#-----------function check zombie process
sub zombie_check {
	my $check;
	my $zombie_ck = `ps afx | grep "dpi-engine" | grep defunct | grep -v grep`;
	if ($zombie_ck eq "") {
		$check=0;
		$textmsg_zcheck=' No zombie processes.';
	}
	else {
		$check=1;
		$textmsg_zcheck=' Achtung! Found ZOMBIE!';
		if ($text_out==$refresh_timer && $relay_for_text == 1) {
			system("echo $datestring 'Achtung! Found ZOMBIE in process list!' >> $watchdog_log");
			$relay_for_text = 0;
		}
	}
	return $check;
}

#--------starting function
sub start {
	$CWD = '/usr/adm/adm_s1';
    system('./start');
    print "$datestring Starting DPI-Engine.\n";
    system("echo $datestring 'Starting DPI-Engine.' >> $watchdog_log");

}

#--------restart function
sub restart {
	$CWD = '/usr/adm/adm_s1';
	system('./stop');
	system('./start');	
	print "$datestring Restarting DPI-Engine.\n";
	system("echo $datestring 'Zombie found. Restarting DPI-Engine.' >> $watchdog_log");
}

#--------big function (main function of this script)
sub watch_dog {
	if (zombie_check()==1) { restart(); return 1; }
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
		if (status() == 0) {
			print "Everything is allright\n";
		}
		else {
			print "Something is wrong. Bypass mode is on.\n";
		}
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
		#-----------REMEMBER: add the real function of bypass|
		system("echo 'Bypasss is onnnN!'");#                 |
		#----------------------------------------------------|
		send_mail("$server bypass status is ON","$datestring $stat");
		system("echo $datestring 'Bypass turn on'");
		system("echo $datestring 'Bypass turn on' >> $watchdog_log");
		bypass_loop();  #-------------------------------------comment this if version for Fastlink
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
	if ($bypass_off_time - $bypass_on_time <= 50) {
		if ($text_out == $refresh_timer) {
			print "$datestring save system state, because bypass is recently ON\n";
			system("echo $datestring ' save system state, because bypass is recently ON' >> $watchdog_log");
			$text_out = 0;
		}
		else {$text_out++;}
	}
	else {
		$bypass=0;
		#-----------REMEMBER: add the real function of bypass|
		system("echo 'Bypasss is oFFFFFFFFuuuuu'");#         |
		#----------------------------------------------------|
		send_mail("$server bypass status is OFF","$datestring Bypass is off");
		system("echo $datestring 'Bypass turn off'");
		system("echo $datestring 'Bypass turn off' >> $watchdog_log");
	}
}
