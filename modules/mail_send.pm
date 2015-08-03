package modules::mail_send;

=pod
This module is required for sending status of the bypass via email 
=cut

use strict;
use warnings;
use Exporter;

#--my libraries
use lib '/home/mihail/Develop/Watch_dog/common';
use common::variables;

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION     = 1.7.0;
    # Inherit from Exporter to export functions and variables
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(send_mail);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw();
}

my $from;

sub send_mail { #<--- CHECK THIS
	my ($subject, $message) = (@_);
    if ($revision eq "debug") {
        $from = 'mikhail.kozlov@adm-systems.com';
    }
    elsif ($revision eq "release") {
        $from = 'notifier.adm@gmail.com';
    }
	my $to = 'mikhail.kozlov@adm-systems.com';
	open(MAIL, "|/usr/sbin/sendmail -t");
    
	# Email Header
	print MAIL "To: $to\n";
	print MAIL "From: $from\n";
	print MAIL "Content-type: text/html\n";
    if ($revision eq "debug") {
        print MAIL "Cc: Coffe-man\@mail.ru\n";
    }
    elsif ($revision eq "release") {
       print MAIL "Cc: yuriy\@adm-systems.com\n";
       print MAIL "Cc: a.matyzhonok\@adm-systems.com\n";
    }
	print MAIL "Subject: $subject\n\n";
	
	# Email Body
	print MAIL $message;
	close(MAIL);
	print "Email Sent Successfully\n";
}

1;
