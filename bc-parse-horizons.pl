#!/bin/perl

# Requested ton of data from HORIZONS, now to parse it
# not sure how useful this is to anyone, but ...

require "bclib.pl";

$targetdir = "/home/barrycarter/20110916/";
chdir($targetdir);
open(A,"bzcat /home/barrycarter/mail/HORIZONS-ssbc.mbx.bz2|");

while (<A>) {
  # key/value pair (sadly, data lines contain colon too, so hack)
  if (/^(.*?):(.*)$/ && !/^2/) {
    ($key, $val) = ($1, $2);
    # cleanup
    $val=~s/[\(|\{].*?[\)|\}]//isg;
    $val=~s/\s//isg;
    $hash{$key} = $val;
    if ($key=~/time|body/) {debug("$key -> $val");}

    # for special key value pairs
    if ($key=~/Target body name/) {
      close(B);
      # writing to "dir of day" just for now
      open(B, ">>pos-$val.txt");
      next;
    }
  }

  # kludge, but I think all Julian dates I care about start w/ 2
  unless (/^2/) {next;}

  s/E/*10^/isg;
  ($jd, $junk, $x, $y, $z) = split(/\,/,$_);

  # I appear to be missing files/years, so adding this
  $junk=~/(\d{4})/;
  $year = $1;

  # Mathematica form
  print B "{$year, $jd, $x, $y, $z},\n";
}

close(B);

# remove dupes
for $i (glob("pos-*")) {
  $i=~/pos-(.*?)\.txt/;
  $name = lc($1);
  debug("WORKING: $name");
  write_file("$name = {\n", "final-$i");
  system("sort $i | uniq >> final-$i; echo '};' >> final-$i");
}

