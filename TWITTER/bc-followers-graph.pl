#!/bin/perl

# graphs number of followers for beta test users over time
require "/usr/local/lib/bclib.pl";

# this should find most of the logs files
# TODO: check for other log files not found here
# my($out,$err,$res) = cache_command2("bzfgrep -h FF: /home/barrycarter/201306*/*stream*.txt*","age=3600");

# below for just latest logfile
my($out,$err,$res) = cache_command2("bzfgrep -h FF: /home/barrycarter/20130623/*stream*.txt*","age=3600");
$stime = str2time("20130623 211156 UTC");

for $i (split(/\n/,$out)) {
  # only lines that actually count followers (not friends + not other debugs)
  unless ($i=~/\[(\d{8}\.\d{6})\] FF: (.*?) has (.*?) followers/) {next;}
  my($time,$user,$fol) = ($1,$2,$3);
  debug("I: $i");
  # I lazily use literal +1 in logs
  if ($fol=~s/\+1$//) {$fol++;}
  # find unix time
  $time=~s/\./ /isg;
  $time=str2time("$time UTC");
  $followers{$user}{$time} = $fol;
}

for $i (sort keys %followers) {
  open(A,">/tmp/$i-followers.txt");
  # for gnuplot
  push(@files,qq%"/tmp/$i-followers.txt" title "$i" with linespoints%);
  for $j (sort keys %{$followers{$i}}) {
    # TODO: this is a glitch, I should fix it in main program too
    # multiples of 5000 usually mean I didnt get all followers
    if ($followers{$i}{$j}%5000==0) {next;}
    # time in days since Jun 1st
    $time = ($j - $stime)/86400;
    unless ($baseline{$i}) {$baseline{$i} = $followers{$i}{$j};}
    $foldelta = $followers{$i}{$j} - $baseline{$i};
    print A "$time $foldelta\n";
  }
  close(A);
}

$files = join(",",@files);

open(A,"|gnuplot -persist");
print A "plot $files\n";
close(A);

