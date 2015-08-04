package modules::check_drops;

=pod
This module checking drops in DPI
=cut

use strict;
use warnings;
use Exporter;

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/scripts';
use scripts::start;
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(check_drops);
}

my $timeCheckCNRdrops = 0; # initial time to check "can not read drop rate"

sub check_drops {
    my $check;
    my $line = `tail -n 28 $log_file | grep "dropRate this moment"`;
    if ($shaper_type eq 'twin' && $line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)\s+(\d.*)\s/){ #when master and slave
        $drop_rate1 = $1;
        $drop_rate2 = $2;
       	if($drop_rate1 > $max_drops || $drop_rate2 > $max_drops){
        	$check=1;
            $textmsg_cdrops = ' Drops level exceeds the configured maximum of drops';
            $logmsg_cdrops = ' bypass is on, droprate is = ';
        }
       	else{
            $check=0;
            $textmsg_cdrops=' Drops level is in normal range';
		}
    }
    elsif ($shaper_type eq 'one' && $line =~ m/dropRate this moment\s+(\d.*)\s+(\d.*)\s/){
        $drop_rate1 = $1;
        $drop_rate2 = $2;
       	if($drop_rate1 > $max_drops || $drop_rate2 > $max_drops){
        	$check=1;
            $textmsg_cdrops = ' Drops level exceeds the configured maximum of drops';
			$logmsg_cdrops = ' bypass is on, droprate is = ';
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
			$logmsg_cdrops = ' bypass is on, Can not read drop rate!';
			$droprate_read = 0;	
		}
	}
    
	return ($drop_rate1, $drop_rate2, $max_drops, $check);
}

1;