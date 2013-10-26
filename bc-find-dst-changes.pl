#!/bin/perl

require "/usr/local/lib/bclib.pl";

# find all DST changes and alert me on the prior thu, fri, sat, sun

my($out,$err,$res) = cache_command2("zdump -v MST7MDT","age=86400");
for $i (split(/\n/,$out)) {
  my($tz, $wd, $mo, $da, $time, $year) = split(/\s+/, $i);
  # my "warning" program doesn't handle dates past 2030
  if ($year < 2013 || $year>=2030) {next;}
  # zdump pumps out "duplicates" of a sort
  if ($seen{"$mo$da$year"}) {next;}
  $seen{"$mo$da$year"}=1;

  # 12:00:00 to avoid corner cases
  my($sec) = str2time("$mo $da $year 12:00:00");

  # alerts 3 to 0 days ahead
  for $j (0..3) {
    print strftime("%Y%m%d DST change this Sunday, follow DST CHANGE PROCEDURE\n", localtime($sec-86400*$j));
  }
}

