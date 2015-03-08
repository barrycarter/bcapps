#!/bin/perl -0777
# note: above slurps STDIN in one gulp

# wraps msmtp to create a mini version of "sendmail -t" even if you
# dont have a smart relay

require "/usr/local/lib/bclib.pl";

# copy stdin to file (which we wont erase since were testing)
# this is bad because it makes a system call
# TODO: Time::HiRes (although it doesnt have a nanosecond?)
# pmail = psuedo mail
$file = "/var/pmail/".`date +%Y%m%d.%H%M%S.%N`;
$file=~s/\s*$//isg;
write_file(<STDIN>,"$file.pre");




