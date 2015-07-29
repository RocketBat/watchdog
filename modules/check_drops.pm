package modules::check_drops;

=pod
This module checking drops in DPI
=cut

############
# Build 6  #
############

use strict;
use warnings;
use Exporter;

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/configs';
use configs::main;
use lib '/home/mihail/Develop/Watch_dog/scripts';
use scripts::start;
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

#--initialise logging config
Log::Log4perl::init('/home/mihail/Develop/Watch_dog/configs/log.conf');
my $logger = Log::Log4perl->get_logger("wd_info");

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION     = 1.7.0;
    # Inherit from Exporter to export functions and variables
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(check_drops);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

my $timeCheckCNRdrops = 0; # initial time to check "can not read drop rate"

sub check_drops {
    my $check;
    my $line = `tail -n 28 $log_file | grep "dropRate this moment"`;
    if ($line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)\s+(\d.*)\s/){
        $drop_rate1 = $1;
        $drop_rate2 = $2;
       	if($drop_rate1 > $max_drops || $drop_rate2 > $max_drops){
        	$check=1;
            $textmsg_cdrops = ' Drops level exceeds the configured maximum of drops';
			if ($text_out==$refresh_timer) {
				system("echo $datestring 'bypass is on, droprate is = $drop_rate1 and $drop_rate2' >> $watchdog_log");
				$logger->info("bypass is on, droprate is = $drop_rate1 and $drop_rate2");
			}
        }
       	else{
            $check=0;
            $textmsg_cdrops=' Drops level is in normal range';
		}
    }
    else{
		$check = 0; #--need for return value
        if (time() - $timeCheckCNRdrops <= $readDropRateDelay) { 
            $droprate_read++;
        }
        else {
            $droprate_read = 0; #--relevance "not read the log" has passed
        }
		if ($droprate_read == $readDropRateDelay) {
			$check=1;
            $timeCheckCNRdrops = time();
			$textmsg_cdrops = ' Can not read drop rate';
			if ($text_out==$refresh_timer) {
				system("echo $datestring 'bypass is on, Can not read drop rate!' >> $watchdog_log");
				$logger->info("bypass is on, Can not read drop rate!");
			}
		$droprate_read = 0;	
		}
	}
	return ($drop_rate1, $drop_rate2, $max_drops, $check);
}

1;