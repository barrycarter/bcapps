#!/bin/perl

# Attempts to create better maps for EL using el-wiki.net information

# Desert Pines = first example

require "bclib.pl";
($all) = cmdfile();
chdir(tmpdir());

warn("Setting keeptemp for now"); $globopts{keeptemp} = 1;

for $i (split("\n",$all)) {
  # are we in a new section?
  if (/== (.*?) ==/) {$section = $1; next;}

  # does this line have coordinates (maybe more than one)
  @coords = ();
  while ($i=~s/\[(\d+\,\d+)\]//) {
    push(@coords, $1);
  }

  unless (@coords) {
#    debug("No coords, skipping");
    next;
  }

  # ignore [[File:thing]]
  $i=~s/\[\[file:.*?\]\]//isg;

  # look for the first [[thing]]; if none, use first word as name
  if ($i=~/\[\[(.*?)\]\]/) {
    $name = $1;
  } else {
    $name = $i;
    $name=~s/\s.*$//;
  }

#  debug("$name, COORDS:",@coords);

  # x,y on DP map translates to x/384*1024, 1024-y/384*1024
  for $j (@coords) {
    debug("J: $j");
    ($mapx, $mapy) = split(/\,/,$j);
    ($picx, $picy) = (round($mapx/384*1024), round(1024-$mapy/384*1024));
    debug("$name -> $picx,$picy");
    push(@pic, "string 255,0,0,$picx,$picy,giant,$name");
  }
}

$pic = << "MARK";
new
size 1024,1024
setpixel 0,0,0,0,0
MARK
;

# TODO: this is ugly
$pic .= join("\n",@pic)."\n";

write_file($pic,"pic.fly");
system("fly -i pic.fly -o pic.gif");
debug("RESULTS:");
system("pwd");

=item info

Info from bloodsucker map:

x=50 -> 133
x=100 -> 266

y=50 -> 891
y=350 -> 90

=cut
