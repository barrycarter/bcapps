#!/bin/perl

# Given a list of MD5 sums in Mac OS X format:
# MD5 (filename) = (hash)
# confirm present each set of equal files but delete nothing
# this is just an aid to the end user, doesn't actually do anything

require "/usr/local/lib/bclib.pl";

my(%count,%files,$count);

while (<>) {
  unless (/^MD5 \((.*)\) = ([0-9a-f]{32})$/) {warn("BAD LINE: $_"); next;}
  my($file, $md5) = ($1,$2);

  # confirm file existence
  unless (-f $file) {warn("NO SUCH FILE: $file"); next;}

  # note it as a list of files for this hash, and number hash to
  # present in order
  $files{$md5}{$file} = 1;
  unless ($count{$md5}) {$count{$md5} = ++$count;}
}

for $i (sort {$count{$a} <=> $count{$b}} keys %count) {
  # if only one existing file for this hash, do nothing; else print
  @keys = keys %{$files{$i}};
  if ($#keys==0) {next;}

  print "FILES FOR $i:\n\n";

  # putting files in quotes makes it easier to delete them
  for $j (@keys) {print qq%"$j"\n%;}

  print "\n"x3;
}
