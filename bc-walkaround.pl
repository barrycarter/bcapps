#!/bin/perl

# Reminds me to get up and walkaround regularly (via cron), unless a
# reminder is already on screen

# Tried this as simple cron job "pgrep -f 'walkaround' || xmessage get
# up and walkaround &", but the shell started by cron matches
# 'walkaround', ha!

require "/usr/local/lib/bclib.pl";

$msg = "get up and walkaround";
# already running? If so, do nothing
$res = system("pgrep -f '$msg'");
unless ($res) {exit(0);}

# record that this message popped up (can be useful)
# my normal 'diary' file is /home/barrycarter/TODAY/yyyymmdd.txt, but
# I'm not quite prepared to append to that (yet)
my($file) = strftime("/home/barrycarter/TODAY/%Y%m%d-extra.txt", localtime($now));
my($time) = strftime("%H%M%S", localtime($now));
append_file("$time $0: xmessage posted\n",$file);
system("xmessage -geometry 1024 get up and walkaround &");
