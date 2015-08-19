package modules::filerefresh;

=pod
This module checking that dpi log is updating
=cut

use POSIX qw(strftime);
use strict;
use warnings;
use File::stat;
use Exporter;

#--my libraries
use lib '/home/mihail/Develop/watch_dog/scripts';
use scripts::start;
use lib '/home/mihail/Develop/watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(filerefresh);
}

#check log for it's updating
sub filerefresh {
    my $obnovlenie;
    my $mt = stat($log_file);
    my $st = $mt -> mtime;
    if ($st +2 >= time()) {
        $textmsg_fresh=' Log file updating ';
        $logmsg = ' Log file updating';
        $obnovlenie=0;
    }
    else {
        $obnovlenie=1;
        $textmsg_fresh = ' Achtung! Log does not updating!';
        $logmsg = ' bypass on, Log does not updating!';
}
    return $obnovlenie;
}

1;