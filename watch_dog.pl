#!/usr/bin/perl
use POSIX qw(strftime);
use strict;
use warnings;
use File::stat;

my $max_drops = 0.04;
#print "Устанавливаем макс. значение потерь = $max_drops*100 %\n"; 

my $directory = '/usr/adm/adm_s1/logs/';
opendir (DIR, $directory) or die $!;

#my $filelog = 'out.log';

my $date = strftime "%F", localtime;

while (my $file = readdir(DIR)) {

 if($file =~ m/$date-out.log/){

  my $log_file = $directory.$file;

    while (1){

      my $datestring = strftime "%F %T", localtime;

#--------------------check drops
	
        my $line = `tail -n 28 $log_file | grep "dropRate this moment"`;
        if ($line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)/){
       	my $drop_rate1 = $1;
	
#		print "Droprate in this moment $1\n";

        	if($drop_rate1 > $max_drops){
        
			print "$datestring Drops level $drop_rate1 exceeds the configured maximum of $max_drops\n";
#-----------------------------Vkl bypass
		        system('echo "with LOL by the pass"');
#------------------------------	
			system("echo $datestring 'bypass is on' >> ./bypass.log");
			print "Bypass is switched on.\n";
#--------Proverka 4to dropi = 0 i perrevod traffica na osnovu
			
      			for (my $i=0;$i < 3;$i++){ 
			
				$line = `tail -n 28 $log_file | grep "dropRate this moment"`;
			        $line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)/;
				$drop_rate1 = $1;
				
				my $co = 40-($i+1)*10;
#				print "Chekaem.I esli vse norm to 4erez $co perevod na osnovu.\n";
				sleep 10;
				if ($drop_rate1 == 0) {
					print "Check.And if al $co perevod na osnovu.\n";
					print "Dropi $drop_rate1\n";
					if ($i == 2) {print "Transfer traffic to main\n";}
				}
				else {
				      print "Anything wrong stay bypass.\n";
				      print "Drop rate is $drop_rate1\n";
				      redo;	
					}
			 
			}
			#sleep 5;
		}
	
		else{
	          	print "$datestring Drops level $drop_rate1 is in normal range\n";
                        }      
 		
      }
      else{
        	print "$datestring Can not read drop rate\n";
#------------Vkl bypass
		system('echo "with LOL by the pass"');
#---------------------
		system("echo $datestring 'bypass is on' >> ./bypass.log");
		print "Bypass is switched on.\n";
		
	
		my $mtime = (stat $log_file)[9];
			if ($mtime =~s/^(\d+)/localtime($1)/e) {
				print "$datestring LOg file updating \n";
				system('echo "snimaem s bypassa na osnovu"');
			}
			else {sleep 10;}
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
	        print "Bypass is switched on.\n";
#tyt kagdie 10 sec proveryaem vkl li bypass
        	
      }
      else{
#	       	print "$datestring Found DPI process in process list\n";
		system("echo $datestring 'Found DPI process in process list' >> bypass.log");
      }



#----proverka obnovlyaetsya li fail
 	my $mtime = (stat $log_file)[9];
	
                   if ($mtime =~s/^(\d+)/localtime($1)/e) {
                        print "$mtime   -   localtime\n";     
			print "$datestring Log file updating \n";
                   }
                   else {
	
			#---------Vkl Bypass
	                system('echo "with LOL by the pass"');
			#------------------ 
			system("echo $datestring 'bypass on' >> ./bypass.log");			
			sleep 5;
			}

      sleep 5;
    }
  }
}

