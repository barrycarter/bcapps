#!/bin/perl

# Sends me a specificed xmessage and SMS at a given time
# Usage: $0 time message
# time must be in format understood by "at"

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

my($time) = shift(@ARGV);
# TODO: catenating remaining args is probably a bad idea
my($msg) = join(" ",@ARGV);

# sendmail command (as Perl function)
$smc = "bc-call-func.pl sendmail $private{email}{from} $private{email}{sms} '$msg'";

open(A,"|at -v $time")||die("Can't open at command, $!");
# TODO: is TERM setting below necessary?
print A "DISPLAY=:0.0; export DISPLAY; TERM=vt100; export TERM; xmessage -geometry 1024 $msg & $smc &";
close(A);

# this uses ifttt.com to send SMS
# TODO: FAIL!!! this can't occur right away
# sendmail($private{email}{from}, $private{email}{sms}, $msg, "");

# TODO: also add alarm text to bg image?
