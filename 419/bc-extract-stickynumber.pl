#!/bin/perl

# extracts call records from "save as webpage complete" of
# stickynumber log pages

require "/usr/local/lib/bclib.pl";

# TODO: location below is temporary
@tds = `fgrep -h '<td>' /home/barrycarter/20130224/stick*.html`;

# debug(@tds);

# NOTE: 4 tabs good, otherwise bad

for $i (@tds) {
  unless ($i=~s%^\t\t\t\t<td>(.*?)</td>%$1%) {next;}
  my($cell) = $1;
  if ($cell=~/<input/) {next;}
  push(@t2,$cell);
}

#debug("T2",@t2);

print "<table border>\n";

for ($i=0; $i<=$#t2; $i+=5) {
  print "<tr><td>";
  print join("</td><td>", @t2[$i..$i+4]);
  print "</td></tr>\n";
}

print "</table>\n";



