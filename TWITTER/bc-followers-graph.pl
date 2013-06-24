#!/bin/perl

# graphs number of followers for beta test users over time
require "/usr/local/lib/bclib.pl";

# this should find most of the logs files
# TODO: check for other log files not found here
my($out,$err,$res) = cache_command2("bzfgrep -h FF: /home/barrycarter/201306*/bc-stream*.txt*","age=3600");

for $i (split(/\n/,$out)) {
  # only lines that actually count followers (not friends + not other debugs)
  unless ($i=~/\[(\d{8}\.\d{6})\] FF: (.*?) has (.*?) followers/) {next;}
  my($time,$user,$fol) = ($1,$2,$3);
  # I lazily use literal +1 in logs
  if ($fol=~s/\+1$//) {$fol++;}
  debug("$time/$user/$fol");
}

