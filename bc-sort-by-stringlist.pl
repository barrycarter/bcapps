#!/bin/perl

# Given a file with a list of strings, prepend a number to each line of
# the stdin corresponding to which string it first maches; if no
# string is matched, prepend -1 to string

# piping the output of this to "sort -n" allows lines in STDIN to be
# sorted in file-defining-substrings order

require "/usr/local/lib/bclib.pl";

# TODO: you can run this program on the list of strings itself to find
# redundant substrings (eg, "xyz" below "xy" can never match, since
# "xy" will capture all "xyz"); however, aborting the for loop early
# below means this probably won't help much

my($sfile) = @ARGV;
my(@strings) = split(/\n/,read_file($sfile));
my($cmp);

while (<STDIN>) {
  for $i (0..$#strings) {
    # does this string match stdin?
    $cmp = index($_,$strings[$i]);
    # if yes, print line number and end loop (for this line)
    if ($cmp>-1) {print "$i $_"; last;}
  }

  # if $cmp is still -1, print that instead
  if ($cmp == -1) {print "-1 $_";}
}

# fgrep --color=always -af matchstrings.txt file.txt > output.txt
