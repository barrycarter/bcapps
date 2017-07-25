#!/bin/perl

# takes a screenshot every minute (from cron) so I can review what I
# did during the day.
# <h>Results: 1955-2015: nothing</h>

# 25 Jul 2017: moved dir to /home/user/XWD more generic location

require "/usr/local/lib/bclib.pl";

my($dir) = "/home/user/XWD";

unless (mylock("bc-xwd.pl","lock")) {die("Locked");}

unless (-d $dir) {die "$dir does not exist";}

# TODO: put in yyyymmdd subdir automatically?
# this was originally a cron job with the below, but I wanted to add locking
system("xwd -root | convert xwd:- $dir/pic.`date +\%Y\%m\%d:\%H\%M\%S`.png");

mylock("bc-xwd.pl","unlock");
