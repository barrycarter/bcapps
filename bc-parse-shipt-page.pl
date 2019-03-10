#!/bin/perl

# attempts to parse shipt page of items

require "/usr/local/lib/bclib.pl";

my($data, $file) = cmdfile();

while ($data=~s%<li.*?>(.*?)</li>%%) {
  my($item) = $1;
  my(@list) = ();

  while ($item=~s%<div[^>]*?>(.*?)</div>%%) {
    my($div) = $1;
    $div=~s%<.*?>%%g;
    if ($div) {push(@list, $div);}
  }

  unless (@list) {next;}

  debug(toOz($list[1]));

  if (@list) {print "$list[2] $list[0] $list[1]\n";}
}


sub toOz {
  my($quant) = @_;

  # simple oz
  if ($quant=~/^([\s\d\.]+)oz$/) {return $1;}

  # if it's x ct; n oz, it's still n oz total
  if ($quant=~/ct;\s*([\d\.]+)\s+oz$/) {return $1;}

  # same with x oz, n ct
  if ($quant=~/^([\s\d\.]+)oz,\s*\d+\s*ct$/) {return $1;}
  
  debug("QUANT: $quant");
}

