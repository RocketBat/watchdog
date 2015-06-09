#!/usr/bin/perl
use POSIX qw(strftime);
use strict;
use warnings;

my $max_drops = 0.04;
#print "Устанавливаем макс. значение потерь = $max_drops*100 %\n"; 

my $directory = '/usr/adm/adm_s1/logs/';
opendir (DIR, $directory) or die $!;

my $filelog = 'out.log';

my $date = strftime "%F", localtime;

while (my $file = readdir(DIR)) {

 if($file =~ m/$date-out.log/){

  my $log_file = $directory.$file;

    while (1){

      my $datestring = strftime "%F %T", localtime;

#--------------------check drops
	
        my $line = `tail -n 28 $log_file | grep "dropRate this moment"`;

#	if ($line =~ m/drop rate = (0.\d\d\d\d\d\d)/){

        if ($line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)/){

        	my $drop_rate1 = $1;
	
		print "Droprate in this moment $1\n";

        	if($drop_rate1 > $max_drops){
        
			print "$datestring Drops level $drop_rate1 exceeds the configured maximum of $max_drops\n";
#-----------------------------Vkl bypass
		        system('echo "with LOL by the pass"');
#------------------------------	
			system("echo $datestring 'bypass is on' >> ./bypass.log");
			print "Bypass is switched on.\n";
			}
# kod dlya vosstanovleniya DPI posle dropov	
		#	if ($drop_rate1 < 0.01) {
		#		print "Startuem DPI, dropi = $1";
		#		system ("$datestring 'Starting DPI, droprate = $1' >> ./bypass.log");
#     				exit;
		#	}
		#	else {
		#		sleep 10;
		#	}

       		else{
	          print "$datestring Drops level $drop_rate1 is in normal range\n";
       		}
      }
      else{
        	print "$datestring Can not read drop rate\n";
#------------Vkl bypass
		system('echo "with LOL by the pass"');
#---------------------
		system('echo $datestring "bypass is on" >> ./bypass.log');
		print "Bypass is switched on. Exiting..\n";
# zdec kagdie 10 sec proveryaem dropi i vkl li bypass voobshe
#sdelat' proverku po vremeni izmeneniya faila *out.log
#        	exit;
      }

#---------------check process


       my $process_status = `ps afx | grep "dpi-engine" | grep -v grep`;
	if ($process_status eq ""){
        	print "$datestring Did not find DPI process in process list\n";
#---------Vkl Bypass
        	system('echo "with LOL by the pass"');
#------------------	
		system("echo $datestring 'bypass on' >> ./bypass.log");
	        print "Bypass is switched on. Exiting..\n";
#tyt kagdie 101 sec proveryaem vkl li bypass
        	exit;
      }
      else{
#        	print "$datestring Found DPI process in process list\n";
		system("echo $datestring 'Found DPI process in process list' >> /log/adm_s1/out.log");
      }

      sleep 5;
    }
  }
}

