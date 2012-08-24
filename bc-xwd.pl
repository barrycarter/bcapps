#!/bin/perl

# takes a screenshot every minute (from cron) so I can review what I
# did during the day.
# <h>Results: 1955-2012: nothing</h>

require "/usr/local/lib/bclib.pl";

unless (mylock("bc-xwd.pl","lock")) {die("Locked");}

# this was originally a cron job with the below, but I wanted to add locking
system("xwd -root | convert xwd:- /home/barrycarter/XWD/pic.`date +\%Y\%m\%d:\%H\%M\%S`.png");

mylock("bc-xwd.pl","unlock");
