#!/bin/perl

# creates digraphs from conquerclub.com XML files
# --img: create images (which can be VERY large, so not done by default)

# TODO: does NOT include bombards

push(@INC,"/usr/local/lib");
require "bclib.pl";

for $file (@ARGV) {
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
    $name=$1;

    # and borders
    @bor=($i=~m%<border>(.*?)</border>%isg);

    # connection map
    for $j (@bor) {$EDGE{$name}{$j} = 1;}
  }
}

# build up graphviz style graph

for $i (keys %EDGE) {
  for $j (keys %{$EDGE{$i}}) {
    # if birectional, note so + remove other direction
    if ($EDGE{$j}{$i}) {
      delete $EDGE{$j}{$i};
      push(@dot,qq%"$i" -- "$j" [dir="both"]%);
      next;
    }

    # otherwise straight arrow
    push(@dot,qq%"$i" -- "$j" [dir="forward"]%);
  }
}

# and print
open(A,">$outfile.dot");
print A "graph x {\n";
print A join("\n",@dot);
print A "\n}\n";
close(A);

# all the graphviz progs: neato and fdp = best graphs, dot = ok, twopi = bad,
# circo = just plain weird
for $i ("dot", "neato", "fdp", "twopi", "circo") {
    # I found these options by trial and error; season to taste
    system("$i -Gepsilon=.000000001 -Gmclimit=5 -Gnslimit=5 -Goverlap=false -Gsplines=true -Nshape=box -Nfontsize=14 -Earrowsize=0.5 -Tsvg $outfile.dot > $outfile-$i.svg");
  }
