#!/bin/perl


# Given three "numbers" (presumably remote server IP address, time in Unix seconds, and local server IP address), generate/print a spamtrap email
my($remote,$time,$local) = @ARGV;
my($domain) = "94y.info";

$addr = sprintf("%02x%02x%02x%02x.%02x.%02x%02x%02x%02x\@94y.info", 
 split(/\./,$remote), $time, split(/\./,$local));

print "<div style='display: none;'><a href='mailto:$addr'>$addr</a></div>\n";

