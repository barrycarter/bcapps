#!/bin/perl

# creates digraphs from conquerclub.com XML files
# --img: create images (which can be VERY large, so not done by default)

# Changed 8 Aug 2010 to use same coords as conquerclub does -- this
# makes the program much duller, but makes the maps better (hopefully)

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
    $name=unidecode($1);

    # record for mathematica
    push(@names,qq%{"$name"}%);

    # get default position (small map) and push
    $i=~m%<smallx>(.*?)</smallx>%;
    $x=$1;
    $i=~m%<smally>(.*?)</smally>%;
    $y=$1;
#    push(@nodes, qq%"$name" [pos="$x,-$y!",label="",style=invis]%);
    $x/=72; $y/=72;
    push(@nodes, qq%"$name" [pos="$x,-$y"]%);

    # for fly (also record position)
    push(@flypoints, "circle $x,$y,5,255,0,0");
    $tx = $x+2;
    $ty = $y+2;
    $count++;
    $nm = substr($name,0,3);
    push(@flytext, "string 255,0,255,$tx,$ty,small,$nm");
    $pos{$name} = "$x,$y";

    # and borders
    @bor=($i=~m%<border>(.*?)</border>%isg);

    # connection map
    for $j (@bor) {$EDGE{$name}{unidecode($j)} = 1;}
  }
}

# build up graphviz style graph

for $i (keys %EDGE) {
  for $j (keys %{$EDGE{$i}}) {
    # if birectional, note so + remove other direction
    if ($EDGE{$j}{$i}) {
      delete $EDGE{$j}{$i};
      $rand=rand();
      push(@dot,qq%"$i" -- "$j" [dir="both",color="$rand,1,1"]%);
      # for mathematica, need both edges
      push(@math,qq%{"$i" -> "$j"}%);
      push(@math,qq%{"$j" -> "$i"}%);

      $edgecount++;

      if ($edgecount%3==1) {
	push(@flylines,"setstyle 255,0,0,255,255,255,255,255,255")
      } elsif ($edgecount%3==2) {
	push(@flylines,"setstyle 0,255,0,255,255,255,255,255,255");
      } elsif ($edgecount%3==0) {
	push(@flylines,"setstyle 0,0,255,255,255,255,255,255,255");
      }

=item COMMENT
      # for fly
     # TODO: need directionals and bomabards
#      if (rand()<.5) {
#	push(@flylines,"setstyle 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255");
	push(@flylines,"setstyle 0,0,255,0,0,0");
      } else {
#	push(@flylines,"setstyle 255,0,255,255,255,255,255,255,255,255,255,255,255,255,255");
	push(@flylines,"setstyle 255,0,255,0,0,0");
      }
=cut

      push(@flylines,"line $pos{$i},$pos{$j},0,0,255");
      next;
    }

    # TODO: consider node-based coloring
    # otherwise straight arrow (or one dir for mathematica)
    push(@dot,qq%"$i" -- "$j" [dir="forward",color="$rand,1,1"]%);
    push(@math,qq%{"$i" -> "$j"}%);
    push(@flylines,"line $pos{$i},$pos{$j},0,0,255");
  }
}

push(@flylines,"killstyle");

debug(@fly);

open(A,">$outfile.fly");
print A "new\nsize 1024,768\nsetpixel 0,0,255,255,255\ntrasparent 255,255,255\n";
print A join("\n",@flylines,@flypoints,@flytext);
close(A);

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
print A "Graph[{$edges},{$verts}]\n";
close(A);

system("neato -Nheight=0.12 -Nwidth=0.65 -Nfixedsize=true -Nshape=box -Nfontsize=8 -Earrowsize=0.33 -Gnslimit=100 -Gmclimit=100 -Gsplines=true -Tpng $outfile.dot > $outfile.png");
