#!/usr/bin/perl
use POSIX qw(strftime);
use strict;
use warnings;
use File::stat;

my $a=0; #----dropi
my $b=0; #----chtenie loga
my $c=0; #----vkl li voobshe dpi
my $d=0; #----vkl li voobshe bypass
my $chk=0; #-------schetchik

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

#----proverka obnovlyaetsya li fail
        my $mt = stat($log_file);
        my $st = $mt -> mtime;
#        print "$st\n";
#	my $fds = time();
#	print "$fds\n";
#                 if ($st =~s/(\d+)/localtime($1)/e) {
		  if ($st +2 >= time()) { 
		       $b=0;
                      print "$datestring Log file updating \n";
                   }
                   else {
                        $b=1;
                        print "$datestring Achtung! Log does not updating!\n";
#---------------------Vkl Bypass
                        system('echo "with LOL by the pass"');
                        $d=1;
#------------------------
                        system("echo $datestring 'bypass on, Log does not updating!' >> ./bypass.log");
                        }

#--------------------check drops
	
        my $line = `tail -n 28 $log_file | grep "dropRate this moment"`;
        if ($line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)/){
       	my $drop_rate1 = $1;
	print "$2\n";
#		print "Droprate in this moment $1\n";

        	if($drop_rate1 > $max_drops){
        		$a=1;
			print "$datestring Drops level $drop_rate1 exceeds the configured maximum of $max_drops\n";
#-----------------------------Vkl bypass
		        system('echo "with LOL by the pass"');
#------------------------------	
			system("echo $datestring 'bypass is on, droprate is = $drop_rate1' >> ./bypass.log");
			print "Bypass is switched on.\n";
			$d=1;
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
					if ($i == 2) {print "Transfer traffic to main\n"; 
							$d=0;}
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
			$a=0;
	          	print "$datestring Drops level $drop_rate1 is in normal range\n";
                        }      
 		
      }
      else{
		$b=1;
        	print "$datestring Can not read drop rate\n";
#------------Vkl bypass
		system('echo "with LOL by the pass"');
		$d=1;
#---------------------
		system("echo $datestring 'bypass is on, Can not read drop rate' >> ./bypass.log");
		print "Bypass is switched on.\n";
      }

#---------------check process


        my $process_status = `ps afx | grep "bin/dpi-engine" | grep -v grep`;
	if ($process_status eq ""){
		$c=1;
        	print "$datestring Did not find DPI process in process list\n";
#---------Vkl Bypass
        	system('echo "with LOL by the pass"');
#------------------	
		system("echo $datestring 'bypass on, Did not find DPI process in process list' >> ./bypass.log");
	        print "Bypass is switched on.\n";
		$d=1;
      }
      else{
		$c=0;
	       	print "$datestring Found DPI process in process list\n";
#		system("echo $datestring 'Found DPI process in process list' >> bypass.log");
      }


#--------------stoping bypass	
if ($a==0 && $b==0 && $c==0 && $d==0) {
		print "vse good\n";
		}
else {

	 for(my $t=0; $chk<3;$t++){
		print "Stay on bypass, if all good transfer traffic to main  \n";		
#--------------------------check drops
		$line = `tail -n 28 $log_file | grep "dropRate this moment"`;
                $line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)/;
                my $drop_rate1 = $1;
		if ($drop_rate1 < $max_drops) {$chk++;}
		else {$chk=0; print "Dropi bolshie ili log bitiy\n";}
#---------------------------check process
		my $process_status = `ps afx | grep "bin/dpi-engine" | grep -v grep`;
	        if ($process_status eq ""){$chk=0; 
			print "Dpi dont run\n";}
		else {$chk++;}
#--------------------------log updating
		my $mt = stat($log_file);
	        my $st = $mt -> mtime;
                if ($st + 2 >= time()) {$chk++;}
		else {$chk=0;print "Log ne obnovl9ets9\n";}
		sleep 5;
	}
}
      sleep 5;
    }
  }
}

