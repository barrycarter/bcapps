#!/bin/perl

# run the command given on the command line:
# if it returns 0, exit 1 from this script
# if it returns 1, exit 0 from this script
# if it returns any other value, exit that value from script

require "/usr/local/lib/bclib.pl";

my(@cmds) = @ARGV;

my($cmd) = $cmds[0];

# debug("COMMAND: $cmd");

my($out, $err, $res) = cache_command2($cmd);

# debug("RES: $res");

# return values are 256 x real values so,

$res >>= 8;

debug("RES: $res");

if ($res == 1) {exit(0);}
if ($res == 0) {exit(1);}

exit($res);

