#!/bin/perl

# converts dict.html to text

require "/usr/local/lib/bclib.pl";

$all = read_file("dict.html");

# debug($all);

while ($all=~s%<b>(.*?)</b>.*?<br>\s*(.*?)</p>%%) {
  ($word, $def) = ($1,$2);
#  print "$1 - $2\n";
  print "$1\n";
}


