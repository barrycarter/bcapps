#!/bin/perl

# downloads all gocomics strips (each day) for a given strip

# <h>Pearls Before Swine = test strip, because of my everlasting hatred
# for Steven Pastis!</h>

require "/usr/local/lib/bclib.pl";

$strip = "pearlsbeforeswine";
$workdir = "/var/tmp/gocomics/$strip";
dodie('chdir("$workdir")');

for $i (1980..2012) {
  for $j (1..12) {
    # for which days this month are comics available?

    # already have it?
    if (-f "days-for-$i-$j.txt") {next;}

    # gocomics requires a user-agent
    push(@commands,"curl -A 'Arthur Fonzarelli' -o days-for-$i-$j.txt http://www.gocomics.com/calendar/$strip/$i/$j");
  }
}

# if there are any commands to run, do so in parallel

if (@commands) {
  write_file(join("\n",@commands), "runme1.sh");
  system("parallel -j 20 < runme1.sh");
}







