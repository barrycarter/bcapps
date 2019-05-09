#!/bin/perl

# quick and dirty hack to print a list stopped processes so user can
# restart them is desired (something bc-daemon-checker2 does after
# enough idle time)

require "/usr/local/lib/bclib.pl";

# this command really does all the work

($out,$err,$res) = cache_command2("ps -wwweo 'pid ppid etime rss vsz stat args'","age=-1");

debug("OUT: $out");

@procs = split(/\n/,$out);
shift(@procs); # ignore header line

for $i (@procs) {

  # cleanup proc line and split into fields
  $i=trim($i);
  $i=~s/\s+/ /isg;
  ($pid,$ppid,$time,$rss,$vsz,$stat,$proc,$proc2,$proc3) = split(/\s+/,$i);

  if ($stat=~/T/) {print "$pid\n";}

}
