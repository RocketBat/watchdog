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

#-----function that checking bypass loop
sub byloop {
	my $t=time();
	if ($t-$t1 > 180) {
		print "$datestring Achtung! Bypass is on 3 times per 3 min! Enabling static bypass by 1 hour!\n"
		system("echo 'Vkl bypass na chas'");
		sleep 10;
	}
	$t1=$t2;
	$t2=$t;
}

#-------------detecting bypass state
if (`cat get_bypass | grep on | grep -v grep` eq "") {
	$bypass=0;
	print "bypass is off\n";
}
else {
	$bypass=1;
	print "bypass is on\n"
}

#-----------function check process
sub process_check {
        my $check;
        my $process_status = `ps afx | grep "dpi-engine" | grep -v grep`;
        if ($process_status eq ""){
                $check=1;
                print "$datestring Did not find DPI process in process list\n";
                system("echo $datestring 'bypass on, Did not find DPI process in process list' >> /home/mihail/Develop/Watch_dog/bypass.log");
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
                        system("echo $datestring 'bypass on, Log does not updating!' >> /home/mihail/Develop/Watch_dog/bypass.log");
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
                        system("echo $datestring 'bypass is on, droprate is = $drop_rate1 and $drop_rate2' >> /home/mihail/Develop/Watch_dog/bypass.log");
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
		system("echo $datestring 'Achtung! Found ZOMBIE in process list!' >> /home/mihail/Develop/Watch_dog/bypass.log");
	}
	return $check;
}

#--------starting function
sub start {
	 $CWD = '/usr/adm/adm_s1';
        system('./start');
        print "$datestring Starting DPI-Engine.\n";
        system("echo $datestring 'Starting DPI-Engine.' >> /home/mihail/Develop/Watch_dog/bypass.log");

}

#--------restart function
sub restart {
	$CWD = '/usr/adm/adm_s1';
	system('./stop');
	system('./start');	
	print "$datestring Restarting DPI-Engine.";
	system("echo $datestring 'Restarting DPI-Engine.' >> /home/mihail/Develop/Watch_dog/bypass.log");
}

#--------big function (main function of this script)
sub watch_dog {
	if (zombie_check()==1) { restart(); return 1; }
        if (process_check()==1 || filerefresh()==1 || Check_drops()==1) {return 1;}
        else {return 0;}
}

while (1) {
    $date = strftime "%F", localtime;
    $log_file = $directory.$date.'-out.log';
    while (1){
		$datestring = strftime "%F %T", localtime;
		(my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();
		if ($hour==3 && $min==0 && $sec < 5) {last;}
		if (watch_dog()==0) {
			print "Everything is allright\n";
			if ($bypass == 0) {
				$bypass=0;
				system("echo $datestring 'Save system state'");
					}
			else {
				$bypass=0;
				system("echo $datestring 'Bypass turn off'");
				system("echo $datestring 'Bypass turn off' >> /home/mihail/Develop/Watch_dog/bypass.log");
				}
		}
		else {
			print "Something is wrong. Starting bypass.\n";
			if ($bypass == 0) {
				$bypass=1;
				byloop();
				system("echo $datestring 'Bypass turn on'");
        	       		system("echo $datestring 'Bypass turn on' >> /home/mihail/Develop/Watch_dog/bypass.log");
					}
			else {
				byloop();
				system("echo 'Save system state'");
				$bypass=1;
				}
		}
		sleep 5;
		}
}
