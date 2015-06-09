#!/usr/bin/perl
use POSIX qw(strftime);
use strict;
use warnings;
use File::stat;

my $bypass=0; #--0-off--|--1-on--
my $max_drops = 0.04;
my $datestring = strftime "%F %T", localtime;;
my $directory = '/usr/adm/adm_s1/logs/';
opendir (DIR, $directory) or die $!;
my $date = strftime "%F", localtime;
while (my $file = readdir(DIR)) {
	if($file =~ m/$date-out.log/){

	  my $log_file = $directory.$file;


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
                        system("echo $datestring 'bypass on, Log does not updating!' >> ./bypass.log");
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
                        system("echo $datestring 'bypass is on, droprate is = $drop_rate1 and $drop_rate2' >> ./bypass.log");
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

#-----------function check process
sub process_check {
        my $check;
	my $process_status = `ps afx | grep "dpi-engine" | grep -v grep`;
        if ($process_status eq ""){
                $check=1;
		print "$datestring Did not find DPI process in process list\n";
                system("echo $datestring 'bypass on, Did not find DPI process in process list' >> bypass.log");
      }
      else{
		$check=0;
		print "$datestring Found DPI process in process list\n";
      }
	return $check;
}

#--------big function
sub watch_dog {
	if (filerefresh()==1 || Check_drops()==1 || process_check()==1) {return 1;}
	else {return 0;}
}

while (1){
	$datestring = strftime "%F %T", localtime;
	if (watch_dog()==0) {
		print "Everything is allright\n";
		if ($bypass == 0) {
			$bypass=0;
			system("echo $datestring 'Save system state'");
				}
		else {
			$bypass=0;
			`bpctl_util all set_bypass off`;
			system("echo $datestring 'Bypass turn off' >> ./bypass.log");
			}
	}
	else {
		print "Something is wrong. Starting bypass.\n";
		if ($bypass == 0) {
			$bypass=1;
			`bpctl_util all set_bypass on`;
        	        system("echo $datestring 'Bypass turn on' >> ./bypass.log");
				}
		else {
			system("echo 'Save system state'");
			$bypass=1;
			}
	}
	sleep 5;
}
}
}
