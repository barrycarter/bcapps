#!/bin/perl

# figure out which services are down (using montastic API + multiple
# accounts) and "report" these to ~/ERR which ultimately prints to my
# background image

require "bclib.pl";

dodie('chdir("/var/tmp/montastic")');
system("rm commands.txt");

# format of this file, each line is "username:password", # starts comments
for $i (split(/\n/,read_file("$ENV{HOME}/montastic.txt"))) {
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}
  ($user,$pass) = split(":",$i);
  append_file("curl -H 'Accept: application/xml' -o $user -u $user:$pass https://www.montastic.com/checkpoints/index\n", "commands.txt");
  push(@users, $user);
}

system("parallel -j 20 < commands.txt");

# look through results
for $i (@users) {
  

