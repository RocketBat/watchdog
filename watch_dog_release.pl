#!/usr/bin/perl
use POSIX qw(strftime);
use strict;
use warnings;
use File::stat;
use File::chdir;

my $bypass; #--0-off--|--1-on--
my $max_drops = 0.04;
my $datestring = strftime "%F %T", localtime;
my $directory = '/usr/adm/adm_s1/logs/';
#opendir (DIR, $directory) or die $!;
my $date = strftime "%F", localtime;
my $log_file;
my $t1=0;
my $t2=0;
my $stat;
my $st; #----error status

#-----function that checking bypass loop
sub byloop {
	my $t=time();
	if ($t1 && $t-$t1 < 180) {
		print "$datestring Achtung! Bypass is on 3 times per 3 min! Enabling static bypass by 1 hour!\n";
		system("echo $datestring 'Achtung! Bypass is on 3 times per 3 min! Enabling static bypass by 1 hour! ' >> /usr/adm/watchdog/logs/bypass.log");
		system("echo 'Vkl bypass na chas'");
		send_mail("KTB bypass status is permanently ON ","$datestring Bypass is ON by 1 hour!");
		sleep 3600;
	}
	$t1=$t2;
	$t2=$t;
}

#---------detecting bypass state
if (`bpctl_util all get_bypass | grep on | grep -v grep` eq "") {
	$bypass=0;
	print "bypass is off\n";
}
else {
	$bypass=1;
	print "bypass is on\n"
}

#----function sending email
sub send_mail {
	my ($subject, $message) = (@_);
	my $from = 'notifier.adm@gmail.com';
	my $to = 'mikhail.kozlov@adm-systems.com';
	open(MAIL, "|/usr/sbin/sendmail -t");
	# Email Header
	print MAIL "To: $to\n";
	print MAIL "From: $from\n";
	print MAIL "Content-type: text/html\n";
	print MAIL "Cc: yuriy\@adm-systems.com\n";
	print MAIL "Cc: a.matyzhonok\@adm-systems.com\n";
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
                print "$datestring Did not find DPI process in process list\n";
                system("echo $datestring 'bypass on, Did not find DPI process in process list' >> /usr/adm/watchdog/logs/bypass.log");
                start();
        }
        else{
                $check=0;
                print "$datestring Found DPI process in process list.\n";
                }
        return $check;
}


#-------------function obnovleniya
sub filerefresh {
        my $obnovlenie;
        my $mt = stat($log_file);
        my $st = $mt -> mtime;
                  if ($st +1 >= time()) {
                        print "$datestring Log file updating \n";
                        $obnovlenie=0;
                  }
                   else {
                        $obnovlenie=1;
                        print "$datestring Achtung! Log does not updating!\n";
                        system("echo $datestring 'bypass on, Log does not updating!' >> /usr/adm/watchdog/logs/bypass.log");
		}
        return $obnovlenie;
}

#------------function check drops
sub Check_drops {
        my $check;
        my $line = `tail -n 28 $log_file | grep "dropRate this moment"`;
        if ($line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)/){
        my $drop_rate1 = $1;
        my $drop_rate2 = $2;
                if($drop_rate1 > $max_drops || $drop_rate2 > $max_drops){
                        $check=1;
                        print "$datestring Drops level $drop_rate1 , $drop_rate2 exceeds the configured maximum of $max_drops\n";
                        system("echo $datestring 'bypass is on, droprate is = $drop_rate1 and $drop_rate2' >> /usr/adm/watchdog/logs/bypass.log");
                        print "Bypass is switched on.\n";
                }
                else{
                        $check=0;
                        print "$datestring Drops level $drop_rate1 and $drop_rate2 is in normal range\n";
                        }
        }
        else{
                $check=1;
	print "$datestring Can not read drop rate\n";
        }
	return $check;
}

#-----------function check zombie process
sub zombie_check {
	my $check;
	my $zombie_ck = `ps afx | grep "dpi-engine" | grep defunct | grep -v grep`;
	if ($zombie_ck eq "") {
		$check=0;
		print "$datestring No zombie processes.\n";
	}
	else {
		$check=1;
		print "$datestring Achtung! Found ZOMBIE!\n";
		system("echo $datestring 'Achtung! Found ZOMBIE in process list!' >> /usr/adm/watchdog/logs/bypass.log");
	}
	return $check;
}

#--------starting function
sub start {
	$CWD = '/usr/adm/adm_s1';
        system('./start');
        print "$datestring Starting DPI-Engine.\n";
        system("echo $datestring 'Starting DPI-Engine.' >> /usr/adm/watchdog/logs/bypass.log");

}

#--------restart function
sub restart {
	$CWD = '/usr/adm/adm_s1';
	system('./stop');
	system('./start');	
	print "$datestring Restarting DPI-Engine.";
	system("echo $datestring 'Restarting DPI-Engine.' >> /usr/adm/watchdog/logs/bypass.log");
}

#--------big function (main function of this script)
sub watch_dog {
	if (zombie_check()==1) { restart(); return 1; }
        if (process_check()==1)	{return 2;}
	if (filerefresh()==1) {return 3;}
	if (Check_drops()==1) {return 4;}
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

while (1) {
    $date = strftime "%F", localtime;
    $log_file = $directory.$date.'-out.log';
    while (1){
		$datestring = strftime "%F %T", localtime;
		(my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();
		if ($hour==3 && $min==0 && $sec < 5) {last;}
		if (status()==0) {
			print "Everything is allright\n";
			if ($bypass == 0) {
				$bypass=0;
				system("echo $datestring 'Save system state'");
					}
			else {
				$bypass=0;
				send_mail("KTB bypass status is OFF","$datestring Bypass is off");
				system("echo $datestring 'Bypass turn off'");
				system("echo $datestring 'Bypass turn off' >> /usr/adm/watchdog/logs/bypass.log");
				}
		}
		else {
			print "Something is wrong. Starting bypass.\n";
			if ($bypass == 0) {
				$bypass=1;
				#my $vr=status(); #need for emailing status
				send_mail("KTB bypass status is ON","$datestring $stat");
				system("echo $datestring 'Bypass turn on'");
        	       		system("echo $datestring 'Bypass turn on' >> /usr/adm/watchdog/logs/bypass.log");
				byloop();
				}
			else {
				system("echo 'Save system state'");
				$bypass=1;
				}
		}
		sleep 5;
		}
}
