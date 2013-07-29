#!/bin/perl

# Given several mail files with the 'From ' (from space) line
# stripped, glue them together and add back the 'From ' line with a
# trivial made-up From line

# sample From line: From example@example.com Tue Dec  9 11:04:04 2008 -0500

require "/usr/local/lib/bclib.pl";
$date = `date`;
chomp($date);

for $i (@ARGV) {
  print "From bc-glue-mail.pl\@example.com $date\n";
  system("/bin/cat $i");
}

