#!/bin/perl

# Runs a nagios test; if a plugin exists, use it; otherwise, use
# subroutines defined here

push(@INC,"/usr/local/lib");
require "bclib.pl";

# what are we being asked to run?
my($cmd) = $ENV{NAGIOS_ARG1};

# split into command and arguments (removing quotes first)
$cmd=~s/\"//isg;
$cmd=~/^\s*(.*?)\s+(.*)$/;
my($bin,$arg) = ($1,$2);

# TODO: allow for non-plugin runs (at which point splitting bin and
# arg will make sense
$run = "/usr/lib/nagios/plugins/$bin $arg";
write_file("RUN: $run","/tmp/bntd.txt");
$res = system($run);

# >>8 converts Perl exit value to program exit value (kind of)
exit($res>>8);

