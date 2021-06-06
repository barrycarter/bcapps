#!/bin/perl

# Usage: $0 function arg1 arg2 ... argn

# this is an ugly hack to run a C function "on the fly"; since C
# doesn't have reflection, this code actually creates source code,
# compiles it, and runs it

require "/usr/local/lib/bclib.pl";

$template = read_file("bc-template-for-perl.c");

my($args) = join(", ", @ARGV[1..$#ARGV]);

$template=~s/# INSERT CODE HERE/printf("%f\\n", $ARGV[0]($args));/;

# TODO: tempfile name should not be fixed, for testing only

write_file($template, "/tmp/code.c");

my($cmd) = "gcc -std=gnu99 -Wall -O2 -I /home/user/SPICE/SPICE64/cspice/include -I $ENV{PWD} /tmp/code.c -o /tmp/code /home/user/SPICE/SPICE64/cspice/lib/cspice.a -lm";

my($out, $err, $res) = cache_command2($cmd);

debug("OUT: $out", "ERR: $err", "RES: $res");

# print($template);

