#!/usr/bin/perl
use POSIX qw(strftime);

my $max_drops = 0.04;

#my $directory = '/usr/adm/adm_s1/logs/';
#opendir (DIR, $directory) or die $!;

#while (my $file = readdir(DIR)) {
#  if($file =~ m/out.log/){

#    my $log_file = $directory.$file;

    while (true){

      my $datestring = strftime "%F %T", localtime;

#--------------------check drops

#      my $line = `tail -n 28 $log_file | grep "dropRate this moment"`;
#	if ($line =~ m/drop rate = (0.\d\d\d\d\d\d)/){
#       if ($line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)/){
#        my $drop_rate1 = $1;
#        my $drop_rate2 = $2;
#        if(($drop_rate>$max_drops)||($drop_rate2>$max_drops)){
#          print "$datestring Drops level $drop_rate1 $drop_rate2 exceeds the configured maximum of $max_drops\n";

#         `bpctl_util all set_bypass on`;
          #`echo "bypass on" > ./bypass_status.txt`;

#          print "Bypass is switched on. Exiting..\n";
#          exit;
#        }
#       else{
#          print "$datestring Drops level $drop_rate1 $drop_rate2 is in normal range\n";
#       }
#      }
#      else{
#        print "$datestring Can not read drop rate\n";
#        `bpctl_util all set_bypass on`;
#	 `echo "bypass on" > ./bypass_status.txt`;
#        print "Bypass is switched on. Exiting..\n";
#        exit;
#      }

#---------------check process


      my $process_status = `ps afx | grep "dpi-engine" | grep -v grep`;
      if ($process_status==""){
        print "$datestring Did not find DPI process in process list\n";

        `bpctl_util all set_bypass on`;
        #`echo "bypass on" > ./bypass_status.txt`;

        print "Bypass is switched on. Exiting..\n";
        exit;
      }
      else{
        print "$datestring Found DPI process in process list\n";
      }

      sleep 5;
    }
#  }
#}
