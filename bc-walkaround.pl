#!/bin/perl

# Reminds me to get up and walkaround regularly (via cron), unless a
# reminder is already on screen

# Tried this as simple cron job "pgrep -f 'walkaround' || xmessage get
# up and walkaround &", but the shell started by cron matches
# 'walkaround', ha!

# note that 'walkaround' itself would match this script, sigh!

$res = system("pgrep -f 'and walkaround'");
# print STDERR "RES: $res\n";
if ($res) {system("xmessage -geometry 1024 get up and walkaround &");}
