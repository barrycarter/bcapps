#!/bin/perl

# creates digraphs from conquerclub.com XML files
# --img: create images (which can be VERY large, so not done by default)

# Changed 8 Aug 2010 to use same coords as conquerclub does -- this
# makes the program much duller, but makes the maps better (hopefully)

# TODO: does NOT include bombards

push(@INC,"/usr/local/lib");
require "bclib.pl";

# TODO: prevent nodes from getting too close to each other
# TODO: choose edge colors better
# TODO: if two nodes share first 12 chars, find way to differentiate
# TODO: doesn't work foriegn characters

# TODO: this does NOT work w/ multiple files -- loop doesn't to end!
for $file (@ARGV) {
  # should end in xml
  unless ($file=~/\.xml$/i) {warn "$file doesn't end in .xml";}

  # base filename for outfile
  $outfile = $file;
  $outfile=~s/\.xml//;

  # get content
  $all=suck($file);

  # find/remove all continents (even if we don't want them, the next regex
  # match doesn't work unless I do this)
  # better way to do below?
  while ($all=~s%<continent>(.*?)</continent>%%is) {push(@cont,$1);}

  # now all territories (could use loop w/ continent?)
  while ($all=~s%<territory>(.*?)</territory>%%is) {push(@terr,$1);}

  # for each territory, find name and borders and create connection map
  for $i (@terr) {
    # name
    $i=~m%<name>(.*?)</name>%;
    $name=unidecode($1);

    # record for mathematica
    push(@names,qq%{"$name"}%);

    # get default position (small map) and push
    $i=~m%<smallx>(.*?)</smallx>%;
    $x=$1;
    $i=~m%<smally>(.*?)</smally>%;
    $y=$1;
    $x/=72; $y/=72;

    # if more than 12 chars, truncate
    $pname = $name;
    if (length($name)>=12) {$pname=substr($name,0,11)."...";}

    push(@nodes, qq%"$name" [pos="$x,-$y",label="$pname"]%);

    # and borders
    @bor=($i=~m%<border>(.*?)</border>%isg);

    # connection map
    for $j (@bor) {$EDGE{$name}{unidecode($j)} = 1;}
  }
}

# build up graphviz style graph

for $i (keys %EDGE) {
  # set color based on point
  $hue+=1/8;
  while ($hue>1) {$hue--;}
  $color="$hue,1,1";

  for $j (keys %{$EDGE{$i}}) {
    # if birectional, note so + remove other direction
    # TODO: code is getting quite redundant -- there's a better way to do this!
    if ($EDGE{$j}{$i}) {
      delete $EDGE{$j}{$i};
      push(@dot,qq%"$i" -- "$j" [dir="both",color="$hue,1,1"]%);

      # for mathematica, need both edges
      # TODO: mathematica code not working -- nodes must be intergers?
      push(@math,qq%{"$i","$j"}%);
      push(@math,qq%{"$j","$i"}%);

      # for networkx need both (and no spaces sigh)
      ($neti, $netj) = ($i,$j);
      $neti=~s/\s/_/isg;
      $netj=~s/\s/_/isg;
      push(@netx,"$neti $netj");
      push(@netx,"$netj $neti");

    } else {
      # otherwise straight arrow (or one dir for mathematica)
      push(@dot,qq%"$i" -- "$j" [dir="forward",color="$hue,1,1"]%);
      push(@math,qq%{"$i","$j"}%);

      ($neti, $netj) = ($i,$j);
      $neti=~s/\s/_/isg;
      $netj=~s/\s/_/isg;
      push(@netx,"$net $netj");
    }
  }
}

# and print
open(A,">$outfile.dot");
print A "graph x {\n";
print A join("\n",@nodes),"\n",join("\n",@dot);
print A "\n}\n";
close(A);

# mathematica version
open(A,">$outfile.m");
$verts = join(",\n",@names);
$edges = join(",\n",@math);
print A "{$edges}\n";
close(A);

# networkx
open(A,">$outfile.py");
print A join("\n",@netx);
print A "\n";
close(A);

system("neato -Nheight=0.12 -Nwidth=0.65 -Nfixedsize=true -Nshape=box -Nfontsize=8 -Earrowsize=0.33 -Gnslimit=100 -Gmclimit=100 -Gsplines=true -Tpng $outfile.dot > $outfile.png");
