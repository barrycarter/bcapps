#!/bin/perl

# JFF, computes the actual delay between following and unfollowing
# (the main program limits how little this delay is, but we don't
# always reach that minimum)

require "/usr/local/lib/bclib.pl";

$|=1;

# latest and greatest log file
# open(A,"tail -f /home/barrycarter/20130619/bc-stream-log.txt | fgrep 'followed at'|");
open(A,"tail -f /home/barrycarter/20130619/bc-stream-log.txt|");

while (<A>) {
  unless (/^\[(\d+)\.(\d+)\].*?followed at (\d+)\)/) {next;}
  # this is bad Perl (but it works)
  my($delay) = str2time("$1 $2 GMT")-$3;
  print "$_\n",convert_time($delay,"%Hh%Mm%Ss"),"\n";
}
