#!/bin/perl

# stop/resume a given PID based on load (probably a bad idea)
require "/usr/local/lib/bclib.pl";

# testing
$pid = 29888;

$loadavg = read_file("/proc/loadavg");
chomp($loadavg);
$loadavg=~s/\s.*$//;

if ($loadavg > 5) {$sig="STOP";} else {$sig="CONT";}
system("kill -$sig $pid");
