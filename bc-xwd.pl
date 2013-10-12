#!/bin/perl

# takes a screenshot every minute (from cron) so I can review what I
# did during the day.
# <h>Results: 1955-2013: nothing</h>

require "/usr/local/lib/bclib.pl";

unless (mylock("bc-xwd.pl","lock")) {die("Locked");}

unless (-d "/mnt/sshfs/XWD") {die "/mnt/sshfs/XWD does not exist";}

# this was originally a cron job with the below, but I wanted to add locking
system("xwd -root | convert xwd:- /mnt/sshfs/XWD/pic.`date +\%Y\%m\%d:\%H\%M\%S`.png");

mylock("bc-xwd.pl","unlock");
