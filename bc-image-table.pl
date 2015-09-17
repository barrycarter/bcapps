#!/bin/perl

# Written so I can create a fake imagemap (an HTML table) for my
# "showoff" Stellarium screenshots, this generically looks at a
# directory of images that have .txt files (from "feh") and builds
# such a table, with thumbnails

require "/usr/local/lib/bclib.pl";

# TODO: make directory user selectable
my(@files) = `find /home/barrycarter/STELLARIUM -iname '*.txt'`;
my(@thumbs);

for $i (@files) {

  chomp($i);
  my($image) = $i;
  $image=~s/\.txt$//;

  $text{$image} = read_file($i);
  $text{$image}=~s/\'/&\#39\;/;

  # create thumbnail unless one exists
  # TODO: allow user to select width
  unless (-f "$image.thumb.png") {
    my($out,$err,$res) = cache_command2("convert -geometry 160x999999 $image $image.thumb.png");
  }

  push(@thumbs,$image);

}

# TODO: alter image to have text at bottom in case people see it sans table

print "<table border><tr>\n";

for $i (@thumbs) {
  print "<td><a href='$i'><img src='$i.thumb.png' title='$text{$i}' /></a></td>\n";
  # TODO: there are better ways to do this (and maybe not even worse ways!)
  if (++$count%5==0) {print "</tr><tr>\n";}
}

print "</tr></table>\n";


