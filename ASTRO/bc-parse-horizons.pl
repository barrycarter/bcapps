#!/bin/perl

# requested more data in different format (CSV) and different plane
# (ICRS) on 22 Aug 2014

require "/usr/local/lib/bclib.pl";

$targetdir = "/home/barrycarter/20140822/";
chdir($targetdir);
open(A,"bzcat /home/barrycarter/mail/HORIZONS19702030.bz2|");

while (<A>) {
  # because results are multipart (many messages per planet), subject
  # is the only reliable means of know where we are
  if (/^Subject: MAJOR BODY \#C\((\d+)\@(\d+)\)_T\((\d+)\) \(\d+\/\d+\)/) {
    close(B);
    open(B,">>pos-$1-$2-$3.txt");
    debug("APPENDING TO: pos-$1-$2-$3...");
    next;
  } elsif (/^Subject: DON\'T DELETE THIS MESSAGE/) {
    # <h>stupid IMAP</h>
    next;
  } elsif (/^Subject/) {
    die("BAD SUBJECT: $_");
  }

  # kludge, but I think all Julian dates I care about start w/ 2
  unless (/^2/) {
#    debug("SKIPPING: $_");
    next;
  }

  s/E/*10^/isg;
  ($jd, $junk, $x, $y, $z) = split(/\,\s+/,$_);

  # I appear to be missing files/years, so adding this
  $junk=~/(\d{4})/;
  $year = $1;

  # Mathematica form
  print B "{$year, $jd, $x, $y, $z},\n";
}

close(B);

# remove dupes
for $i (glob("pos-*")) {
  $i=~/(\d+)\.txt/;
  $name = "planet$1";
  debug("WORKING: $name");
  write_file("$name = {\n", "final-$i");
  system("sort $i | uniq >> final-$i; echo '};' >> final-$i");
}

