#!/bin/perl

# Check to see if a given process (pgrep string) is running on an
# alternate machine, report when it's done running (assumes you can
# "ssh root@remote" passwordlessly, which is probably a bad idea)

# Usage: $0 string:machine [string:machine ...]

push(@INC, "/usr/local/lib");
require "bclib.pl";

# put into hash since I may need to delete later
for $i (@ARGV) {
  ($str,$mach)=split(/\:/, $i);
  $str{$mach} = $str;
}

# loop forever
for (;;) {
  # keylist changes, since I delete below
  @proc = sort keys %str;
  if ($#proc<0) {
    debug("NO PROCS LEFT");
    exit(0);
  }

  for $i (sort keys %str) {
    ($out, $err, $res) = cache_command("ssh root\@$i 'pgrep $str{$i}'");
    debug("RESULT: $out");
    # if there is a (numerical) result, keep going
    if ($out=~/^\d/s) {next;}
    # otherwise, announce result and delete this key
    system("xmessage $i:$str{$i} complete! &");
    delete $str{$i};
  }

  # TODO: 1 for testing only, increase later
  sleep(1);
}

