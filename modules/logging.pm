package modules::logging;

=pod
This module setup output information
=cut

use strict;
use warnings;
use Exporter;

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(textout outlog);
}

sub textout {
	if ($text_out==$refresh_timer) {
		print "$datestring $textmsg_proc \n";
		print "$datestring $textmsg_zcheck \n";
		print "$datestring $textmsg_fresh \n";
		print "$datestring $textmsg_cdrops drop $drop_rate1 and $drop_rate2\n";
	}
}

sub outlog {
	if ($text_out==$refresh_timer) {
		print "$datestring $logmsg_proc \n";
		print "$datestring $logmsg_zcheck \n";
		print "$datestring $logmsg_fresh \n";
		print "$datestring $logmsg_cdrops drop $drop_rate1 and $drop_rate2\n";
	}
}

1;