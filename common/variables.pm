package common::variables;

=pod
This module return all variables in watchdog
=cut

############
# Build 14 #
############

use POSIX qw(strftime);
use strict;
use warnings;
use Exporter;

#--our libraries
#use lib '/home/mihail/Develop/Watch_dog/configs';
#use configs::main;

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION     = 1.0.0;
    # Inherit from Exporter to export functions and variables
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(options $revision $readDropRateDelay $server $t1 $t2 $log_file $textmsg_zcheck $textmsg_cdrops $textmsg_fresh $textmsg_proc $max_drops $datestring $directory $date $stat $refresh_timer $text_out $drop_rate1 $drop_rate2 $bypass_on_time $bypass_off_time $watchdog_log $delay_removal_from_bypass $droprate_read);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

#------SERVER NAME------|
our $server = 'Mighty';#|
#-----------------------|

my $wd_conf = '/home/mihail/Develop/Watch_dog/configs/wd_conf.cfg';

#--main params
our $revision;
our $max_drops = 0.04;
our $refresh_timer = 80; #----speed of logging
our $delay_removal_from_bypass = 90; # this delay needs when Bypass is turned off earlier than necessary
our $readDropRateDelay = 5; # how many times needs to be in "can not read drop rate" state
our $watchdog_log = '/home/mihail/Develop/Watch_dog/bypass.log'; #---CHECK FULL PATH
our $directory = '/usr/adm/adm_s1/logs/';
#--secondary variables
our $datestring = strftime "%F %T", localtime;
our $date = strftime "%F", localtime;
our $stat; #---need for mailing status
our $text_out = 0; #---need for text output
our $drop_rate1 = 0; #--drops upload
our $drop_rate2 = 0; #--drops download
our $bypass_on_time = 0; # last time when bypass is on
our $bypass_off_time = 0; # last time when bypass is off
our $droprate_read = 0; # need for check_drop function? when can not read drop rate
our $textmsg_proc; #---text message processcheck
our $textmsg_fresh; #---text message filerefresh
our $textmsg_cdrops = ' Can not read drop rate!'; #---text message checkdrops
our $textmsg_zcheck; #---text message zombie
our $log_file;
our $t1 = 0;
our $t2 = 0;

#--options
sub options { 
    my @strings = ($revision, $max_drops, $refresh_timer, $delay_removal_from_bypass, $readDropRateDelay, $watchdog_log, $directory);
    for (my $i=0;$i<7;$i++) {
        my $line = `tail -n 12 $wd_conf`;
        if ($line =~ m/*$strings[$i]:\s+(\d.*)/) {$strings[$i] = $1;}
    }
}

1;