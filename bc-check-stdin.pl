#!/bin/perl

# Checks to see if the stdin matches certain conditions

# since this is intended to be used with nagios/nagyerass, exists with
# return code 2 on fail

# --empty: contains only whitespace

# --equals="string": stdin is equal to string, excluding trailing white space

# --sha1="string": excluding trailing white space, stdin's sha1sum is string

require "/usr/local/lib/bclib.pl";

# slurp entire stdin

local($/);

my($all) = <STDIN>;

# TODO: add an option to NOT ignore trailing whitespace

$all=~s/\s*$//;

debug("ALL: $all");

if ($globopts{empty} && $all ne "") {die("STDIN IS NOT EMPTY: $all");}

if ($globopts{equal} && $all ne $globopts{equal}) {
  die("STDIN NOT EQUAL TO: $globopts{equal}");
}

# TODO: implement sha1_hex



