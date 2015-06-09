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
	my $drop_rate2 = $2;
#		print "Droprate in this moment $1\n";

        	if($drop_rate1 > $max_drops || $drop_rate2 > $max_drops){
        		$a=1;
			print "$datestring Drops level $drop_rate1 , $drop_rate2 exceeds the configured maximum of $max_drops\n";
#-----------------------------Vkl bypass
		        system('echo "with LOL by the pass"');
#------------------------------	
			system("echo $datestring 'bypass is on, droprate is = $drop_rate1 and $drop_rate2' >> ./bypass.log");
			print "Bypass is switched on.\n";
			$d=1;
#--------Proverka 4to dropi = 0 i perrevod traffica na osnovu
			
		}
	
		else{
			$a=0;
	          	print "$datestring Drops level $drop_rate1 and $drop_rate2 is in normal range\n";
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

my $co=0;
#--------------stoping bypass	
if ($a==0 && $b==0 && $c==0 && $d==0) {
		print "vse good\n";
		}
elsif($a==0 && $b==0 && $c==0 && $d==1) {

	 for(my $i=0; $i<3;$i++){
		$co = 40-($i+1)*10;
		print "Stay on bypass, if all good after $co sec transfer traffic to main  \n";		
		sleep 10;
#---------------------------check process
                my $process_status = `ps afx | grep "bin/dpi-engine" | grep -v grep`;
                if ($process_status eq ""){$i=0;
                        print "Dpi dont run\n";}
                else {$chk=1;}

#--------------------------log updating
                my $mt = stat($log_file);
                my $st = $mt -> mtime;
                if ($st + 2 >= time()) {$chk=1;}
                else {$i=0;print "Log ne obnovl9ets9\n";}

#------------------------check drops
		$line = `tail -n 28 $log_file | grep "dropRate this moment"`;
                $line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)/;
                my $drop_rate1 = $1;
		my $drop_rate2 = $2;
			if ($drop_rate1 <= $max_drops || $drop_rate2 <= $max_drops) {$chk=1;}
			   else {$i=0;
                                $line = `tail -n 28 $log_file | grep "dropRate this moment"`;
                                $line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)/;
                                $drop_rate1 = $1;
                                $drop_rate2 = $2;
                                my $co = 40-($i+1)*10;
                                sleep 10;
                               		 if ($drop_rate1 == 0 && $drop_rate2 == 0) {
                                        	print "Check.And if all g00d after $co sec perevod na osnovu.\n";
	                                        print "Dropi Up = $drop_rate1 and Down = $drop_rate2\n";
        	                                if ($i == 2) {print "Transfer traffic to main\n";
#------------------------------vik bypass
							print "Bypass ostanovlen\n";
							system("echo $datestring 'Transfer traffic to main state' >> ./bypass.log");
#-----------------------------
               	                                        }
                        		 }
                                	else {
                                	        print "Anything wrong stay bypass.\n";
                                      		print "Drop rate is $drop_rate1 and $drop_rate2 \n";
                                      		redo;
                                        	}

		}
		if ($a==0 && $b==0 && $c==0 && $d==0 && $co==0) {
#------------------------------vik bypass
               			 print "Bypass ostanovlen\n";
                                 system("echo $datestring 'Transfer traffic to main state' >> ./bypass.log");
#-----------------------------
		}
		sleep 5;
	}
}
elsif ($d==1) {print"staying on bypass\n";}
      sleep 5;
    }
  }
}

