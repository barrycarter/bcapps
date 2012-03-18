#!/bin/perl

# Parses HTML downloads from ING DIRECT. Although ING DIRECT (now part
# of Capital One) offers an OFX download, this download clips merchant
# names AND ING DIRECT has conceded the OFX downloads aren't always
# accurate/complete. Thus, the HTML downloads are more useful to me.

# This is another program that's probably useful just to me

require "bclib.pl";
($all,) = cmdfile();

# really should use XML parser, but too lazy
# divs we want start with class= "s4" or "s15"; class="s32" is meta-separator
while ($all=~s%<div class="s[14].*?>(.*?)</div>%%is) {
  $line = $1;

  # ignore until end of headers (month starts with 0 or 1)
  if ($line=~/^[01]/) {$OK=1;}
  debug("OK: $OK");
  unless ($OK) {next;}

  push(@lines, $line);
}

# suck them down 5 fields at a time

while (($date, $desc, $with, $dep, $bal) = @lines[$n..$n+5]) {
  $n+=6;
  debug("DATE: $date");
}


