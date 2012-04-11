#!/bin/perl

# Check to see if a given process (pgrep string) is running on an
# alternate machine, report when it's done running (assumes you can
# "ssh root@remote" passwordlessly, which is probably a bad idea)

# Usage: $0 string:machine [string:machine ...]

push(@INC, "/usr/local/lib");
require "bclib.pl";

# put into hash to make things easier
for $i (@ARGV) {$cmd{$i}=1;}

# loop forever
for (;;) {
  # keylist changes, since I delete below
  @cmds = sort keys %cmd;
  if ($#cmds<0) {
    debug("NO PROCS LEFT");
    exit(0);
  }

  for $i (@cmds) {
    ($str,$mach)=split(/\:/, $i);
    ($out, $err, $res) = cache_command("ssh root\@$mach 'pgrep $str'");
    debug("RESULT: $out");
    # if there is a (numerical) result, keep going
    if ($out=~/^\d/s) {next;}
    # otherwise, announce result and delete this key
    system("xmessage $mach:$str complete! &");
    delete $cmd{$i};
  }

  sleep(15);
}

