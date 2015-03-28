#!/bin/perl

# Sends me a specificed xmessage and SMS at a given time
# Usage: $0 time message
# time must be in format understood by "at"

require "/usr/local/lib/bclib.pl";

my($time) = shift(@ARGV);
# TODO: catenating remaining args is probably a bad idea
my($msg) = join(" ",@ARGV);

open(A,"|at -v $time")||die("Can't open at command, $!");
# TODO: is TERM setting below necessary?
print A "DISPLAY=:0.0; export DISPLAY; TERM=vt100; export TERM; xmessage -geometry 1024 $msg &";
close(A);

