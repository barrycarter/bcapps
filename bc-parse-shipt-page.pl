#!/bin/perl

# attempts to parse shipt page of items

require "/usr/local/lib/bclib.pl";

my($data, $file) = cmdfile();

while ($data=~s%<li.*?>(.*?)</li>%%) {
  my($item) = $1;
  my(@list);

  while ($item=~s%<div[^>]*?>(.*?)</div>%%) {
    my($div) = $1;
    $div=~s%<.*?>%%g;
    if ($div) {push(@list, $div);}
  }

  debug("list", @list);

}


