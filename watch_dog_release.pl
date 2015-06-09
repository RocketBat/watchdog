#!/usr/bin/perl
use POSIX qw(strftime);
use strict;
use warnings;

my $max_drops = 0.04;
#print "Устанавливаем макс. значение потерь = $max_drops*100 %\n"; 

my $directory = '/usr/adm/adm_s1/logs/';
opendir (DIR, $directory) or die $!;

my $filelog = 'bypass_status.txt';

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

         if($drop_rate1>$max_drops){
          print "$datestring Drops level $drop_rate1 exceeds the configured maximum of $max_drops\n";
#------Vkl bypass
	`bpctl_util all set_bypass on`;
#----------------	
	system("echo $datestring 'bypass on' >> ./bypass_status.txt");
	print "Bypass is switched on. Exiting..\n";
          exit;
        }
       else{
          print "$datestring Drops level $drop_rate1 is in normal range\n";
       }
      }
      else{
        print "$datestring Can not read drop rate\n";
#------------Vkl bypass
	`bpctl_util all set_bypass on`;
#---------------------
	system("echo $datestring 'bypass on' >> ./bypass_status.txt");
	print "Bypass is switched on. Exiting..\n";
        exit;
      }

#---------------check process


      my $process_status = `ps afx | grep "dpi-engine" | grep -v grep`;
	if ($process_status eq ""){
        print "$datestring Did not find DPI process in process list\n";
#---------Vkl Bypass
	`bpctl_util all set_bypass on`;
#------------------	
	system("echo $datestring 'bypass on' >> ./bypass_status.txt");
        print "Bypass is switched on. Exiting..\n";
        exit;
      }
      else{
        print "$datestring Found DPI process in process list\n";
      }

      sleep 5;
    }
  }
}
