#!/bin/perl

# converts the SKYCAL calendars from NASA to ICS format

require "/usr/local/lib/bclib.pl";

for $i (glob "$bclib{githome}/ASTRO/SKYCAL*.html") {
  my($all) = read_file($i);

  while ($all=~s%<tr>(.*?)</tr>%%s) {
    my($row) = $1;
    my(@td) = ($row=~m%<td.*?>(.*?)</td>%sg);
    debug("TD",@td);

    debug("1: $1");
  }

}
