#!/bin/perl

# This one shot uploads captions (in data/ directory) to my blog
require "bclib.pl";

for $i (glob "data/*.out.bz2") {
  # convert to readable format
  # NOTE: this is quite ugly
  $title = $i;
  $title=~s%data/%%isg;
  $title=~s/\.out\.bz2$//isg;
  $title=~s/_SE?S?(\d+)_?/, Season $1, /;
  $title=~s/[_|\s]DV?D?(\d+)[_|\s]?/, DVD $1/isg;
  $title=~s/_/ /isg;
  $title = join(" ",map {$_=ucfirst(lc($_))} split(/\s+/, $title));
  $title=~s/Dvd/DVD/isg;
  $title=~s/,+/,/isg;
  $title=~s/,$//isg;
  $title=~s/ And /and/isg;
  $title=~s/Curbyourenthusiasm/Curb Your Enthusiasm/isg;
  $title=~s/Ch Superfriends/Challenge of the Superfriends/;

  # special cases
  %translate = (
		"Borat 16x9" => "Borat (movie)",
		"Bravhart" => "Braveheart (movie)",
		"Conan 10th Ann" => "Conan 10th Anniversary Special"
	       );

  debug("$title");
}
