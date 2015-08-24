#!/bin/perl

# trivial script to parse vjr-conjucts.txt to ultimately answer
# http://astronomy.stackexchange.com/questions/11456/has-the-conjunction-between-venus-jupiter-and-regulus-only-occurred-twice-in-2

require "/usr/local/lib/bclib.pl";

my($all) = read_file("$bclib{githome}/ASTRO/vjr-conjucts.txt");

while ($all=~s/\{+(.*?)\}+//s) {
  my($sunsep,$jday,$jclean,$sep) = split(/\,\s*/,$1);
  $jclean=~s/\"//g;
  my($str) = sprintf("%19s %5.3f %6.3f\n",$jclean,$sep,$sunsep);
  print $str;
}
