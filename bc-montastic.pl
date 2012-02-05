#!/bin/perl

# figure out which services are down (using montastic API + multiple
# accounts) and "report" these to ~/ERR which ultimately prints to my
# background image

# -nocurl: dont actually query montastic API (useful for testing)

require "bclib.pl";

dodie('chdir("/var/tmp/montastic")');

unless ($globopts{nocurl}) {system("rm commands.txt results.txt err.txt");}

# format of this file, each line is "username:password", # starts comments
for $i (split(/\n/,read_file("$ENV{HOME}/montastic.txt"))) {
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}
  ($user,$pass) = split(":",$i);
  append_file("curl -H 'Accept: application/xml' -u $user:$pass https://www.montastic.com/checkpoints/index\n", "commands.txt");
  push(@users, $user);
}

unless ($globopts{nocurl}) {
  system("parallel -j 20 < commands.txt > results.txt");
}

# look at results
$all = read_file("results.txt");

while ($all=~s%<checkpoint>(.*?)</checkpoint>%%is) {
  $res = $1;

  # ignore good results
  if ($res=~m%<status type="integer">1</status>%) {next;}

  # offending URL
  $res=~m%<url>(.*?)</url>%isg;

  # write it to file
  append_file("$1\n","err.txt");
}



