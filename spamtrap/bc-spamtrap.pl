#!/bin/perl

# Given a remote IP address and the server IP address, construct an
# email address of the form remoteip.date.serverip@94y.info as a
# spamtrap

# TODO: update docs above, currently bad
my($remote,$time,$local) = @ARGV;
my($domain) = "94y.info";

$addr = sprintf("%02x%02x%02x%02x.%02x.%02x%02x%02x%02x\@94y.info", 
 split(/\./,$remote), $time, split(/\./,$local));

print "<a href='mailto:$addr'>$addr</a>\n";

