#!/bin/perl

# Uses zenity to create a checkbox list from a file; useful for OCD
# people like me to check stuff off a list

# example command (but going to use apos for convenience):
# zenity --list --checklist --column="" --column="" "" "conquer Earth" \
# "" "conquer Venus" "" "conquer Mars"

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

# because I'm using checklist the first column of each row is blank

for $i (split(/\n/, $data)) {

  # ignore blank lines
  if ($i=~/^\s*$/) {next;}

  # change bad delimiters
  $i=~s/\'/"/g;

  push(@cmd, "'' '$i'");
}

my $cmd = join(" ", @cmd);

my $runme = "zenity --list --checklist --column='' --column='' $cmd"; 

# NOTE: backgrounding this means I never get the result but that's ok

my($out, $err, $res) = cache_command2("$runme&");

# TODO: could I use exec or something or reap my child?


