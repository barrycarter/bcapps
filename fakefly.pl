#!/bin/perl

# attempts to replicate some `fly` functionality using GD

# NOTE: this is a hack to get some other stuff working, it does NOT do
# a good job of replicating fly

use GD;

require "/usr/local/lib/bclib.pl";

my($im);

my(%colorexists);

while (<>) {

  # TODO: setting 0,0,0 to transparent is a hack as is ignoring the x=y=0 pixel

  if (/^size (.*?),(.*)$/) {
    $im = new GD::Image($1,$2);
    my($black) = $im->colorAllocate(0, 0, 0);
    $im->transparent($black);
    next;
  }

  if (/^transparent (.*?)$/) {
    next;
    my($r, $g, $b) = split(/\,/, $1);
    my($col) = $im->colorAllocate($r, $g, $b);
    $im->transparent($col);
    next;
  }

  if (/^setpixel (.*?)$/) {
    my($x, $y, $r, $g, $b) = split(/\,/, $1);

    # ignore the top left "black" pixel since I want transparency
    if ($x+$y+$r+$g+$b == 0 ) {next;}

    # allocate color if necessary
    unless ($colorexists{"$r,$g,$b"}) {
      $colorexists{"$r,$g,$b"} = $im->colorAllocate($r, $g, $b);
    }

    $im->setPixel($x, $y, $colorexists{"$r,$g,$b"});
    next;
  }


  debug("THUNK: $_");

}

binmode STDOUT;
print $im->png;





