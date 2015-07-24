package modules::filerefresh;

=pod
This module checking that dpi log is updating
=cut

############
# Build 1  #
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
    our @EXPORT      = qw(filerefresh);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

sub filerefresh {
    my $obnovlenie;
    my $mt = stat($log_file);
    my $st = $mt -> mtime;
    if ($st +1 >= time()) {
        $textmsg_fresh=' Log file updating ';
        $obnovlenie=0;
    }
    else {
        $obnovlenie=1;
        $textmsg_fresh = ' Achtung! Log does not updating!';
		if ($text_out==$refresh_timer) {
			system("echo $datestring 'bypass on, Log does not updating!' >> $watchdog_log");
			$logger->info("$datestring bypass on, Log does not updating!");
		}
	}
    return $obnovlenie;
}

1;