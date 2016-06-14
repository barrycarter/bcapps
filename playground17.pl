#!/bin/perl

# To help someone create a montage of images/text

require "/usr/local/lib/bclib.pl";

# work directory for this project
chdir("/home/barrycarter/20160613");

my(@text) = split(/\r\n/, read_file("1.txt"));

# make indices match
unshift(@text, "");
debug(@text);

die "TESTING";

my($n) = 0;

print "<table border>\n";

for $i (1..3) {
  print "<tr>\n";
  for $j (1..5) {
    print "<td><img src='$n.jpg'>$text[$n]</td>\n";
    $n++;
  }
  print "</tr>\n";
}

print "</table>\n";
