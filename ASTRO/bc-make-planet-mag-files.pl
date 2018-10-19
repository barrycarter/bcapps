#!/bin/perl

# Quick and dirty script to create combined magnitude/phase files for planets

require "/usr/local/lib/bclib.pl";

%skip = list2hash("halley", "tesla");

for $i (glob "*-brightness.txt.bz2") {

  open(A, "bzcat $i|");
  $i=~s/\-brightness\.txt\.bz2$//;

  if (-f "/tmp/$i-final.txt") {next;}

  # skip where I won't have ephermis data
  if ($skip{$i}) {next;}

  open(B, ">/tmp/$i-0.txt");

  while (<A>) {if ($_=~/^\$\$SOE$/) {last;}}

  while (<A>) {
    if ($_=~/^\$\$EOE$/) {last;}
    my(@fields) = csv($_);
    print B "$fields[0],$fields[5],$fields[6]\n";
  }

  close(A);
  close(B);

  # the moon doesnt have a barycenter (well, it does, but SPICE
  # doesnt know that)

  my($p) = $i eq "moon"?$i:"$i barycenter";
  debug("P: $p");

  my($out, $err, $res) = cache_command2("bc-magnitude '$p' | paste -d, - /tmp/$i-0.txt > /tmp/$i-final.txt", "age=-1");
  debug("ERR: $err");

}

