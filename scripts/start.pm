package scripts::start;

=pod
This module starting DPI
=cut

use strict;
use warnings;
use Exporter;
use File::chdir;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(start);
}

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;
use lib '/home/mihail/Develop/Watch_dog/modules';
use modules::logging;

#starting dpi
sub start {
	$CWD = '/usr/adm/adm_s1';
    system('./start');
    setTextStartDPI();
}

1;