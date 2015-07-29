package common::variables;

=pod
This module return all variables in watchdog
=cut

############
# Build 5  #
############

use POSIX qw(strftime);
use strict;
use warnings;
use Exporter;

#--our libraries
use lib '/home/mihail/Develop/Watch_dog/configs';
use configs::main;

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION     = 1.0.0;
    # Inherit from Exporter to export functions and variables
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw($t1 $t2 $log_file $textmsg_zcheck $textmsg_cdrops $textmsg_fresh $textmsg_proc $max_drops $datestring $directory $date $stat $refresh_timer $text_out $drop_rate1 $drop_rate2 $bypass_on_time $bypass_off_time $watchdog_log $delay_removal_from_bypass $droprate_read);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

our $max_drops = 0.04;
our $datestring = strftime "%F %T", localtime;
our $directory = '/usr/adm/adm_s1/logs/';
our $date = strftime "%F", localtime;
our $stat; #---need for mailing status
our $refresh_timer = 80; #----speed of logging
our $text_out = 0; #---need for text output
our $drop_rate1 = 0; #--drops upload
our $drop_rate2 = 0; #--drops download
our $bypass_on_time = 0; # last time when bypass is on
our $bypass_off_time = 0; # last time when bypass is off
our $watchdog_log = '/home/mihail/Develop/Watch_dog/bypass.log'; #---CHECK FULL PATH
our $delay_removal_from_bypass = 90; # this delay needs when Bypass is turned off earlier than necessary
our $droprate_read = 0; # need for check_drop function? when can not read drop rate
our $textmsg_proc; #---text message processcheck
our $textmsg_fresh; #---text message filerefresh
our $textmsg_cdrops = ' Can not read drop rate!'; #---text message checkdrops
our $textmsg_zcheck; #---text message zombie
our $log_file;
our $t1 = 0;
our $t2 = 0;

1;