#!/bin/perl

# Given the HTML in a quora log entry like
# https://www.quora.com/log/revision/144239526, extract date and text

# --machine: print timestamp and revid in machine format (for graphing/etc)

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {

  my($all);
  if ($i=~/\.bz2$/) {
    $all = join("",`bzcat $i`);
  } else {
    $all = read_file($i);
  }

  # revision number
  unless ($all=~s%<title>Revision \#(\d+) - Quora</title>%%i) {
    warn "NO NUMBER: $i";
    next;
  }

  my($rev) = $1;

  # epoch_us can appear multiple times, we want least value (when log
  # file actually "created" for first time; in pratice, it appears
  # more than once less than 5% of the time
  my(@times) = ();
  while ($all=~s%"epoch_us": (\d+),%%) {push(@times, $1);}
  my($origtime) = min(@times);
  $time = strftime("%Y%m%d.%H%M%S",gmtime(int($origtime/1000000)));

  $all=~s%<span\s+class="rendered_qtext">(.*?)</span>%%is;
  my($q) = $1;

  $all=~s%<div class="revision">(.*?)</div><p class="log_action_bar">%%s;
  my($text) = $1;
  $text=~s/<.*?>//sg;
  $text=~s/[^ -~]//g;
  $text=wrap($text,70);

  if ($globopts{machine}) {print "$origtime $rev\n"; next;}

print << "MARK";
Rev: $rev
Time: $time
Question: $q

Text: $text

MARK
;
}

