#!/bin/perl

# attempts to create a logarithmic "zooming timeline" using google maps

require "/usr/local/lib/bclib.pl";

# get google query
%query = str2hash($ENV{QUERY_STRING});

# for now, only draw on strip below equator
unless ($query{y}==2**($query{zoom}-1)) {exit;}

# convert x to -1 to +1 scale (sx = scaled x)
$sx = $query{x}/2**($query{zoom}-1)-1;
$sx2 = ($query{x}+1)/2**($query{zoom}-1)-1;

# converts google location (on x=[-1,1] scale) to seconds pre/post 1 BCE
sub g2s {
  my($x) = @_;

  # the max log we represent is exp(45) seconds (1.1 trillion years)
  my($logx) = abs($x*45);

  if ($x>0) {return exp($logx);}
  return -exp($logx);
}

# converting seconds to years
$lx = display_sec(g2s($sx));
$rx = display_sec(g2s($sx2));

$printstr = << "MARK";
x=$query{x},y=$query{y},zoom=$query{zoom}
LX: $lx
RX: $rx
SX: $sx
SX2: $sx2
MARK
;

# hideous...
print "Content-type: image/gif\n\n";
open(A,"|fly -q");

print A << "MARK";
new
size 256,256
setpixel 0,0,0,0,255
rect 0,0,256,256,255,0,0
dline 0,128,256,128,255,128,0
dline 128,0,128,256,255,128,0
MARK
;

$y=0;

for $i (split(/\n/, $printstr)) {
  print A "string 255,255,255,2,$y,large,$i\n";
  $y+=20;
}

close(A);

# kludge function to print a large number of seconds nicely?
# TODO: do this much better!

sub display_sec {
  my($s) = @_;

  if ($s<60) {return "$s sec";}
  $s/=60.;
  if ($s<60) {return "$s min";}
  $s/=60.;
  if ($s<24) {return "$s hrs";}
  $s/=24.;
  if ($s<365.2425) {return "$s days";}
  $s/=365.2425;
  return "$s years";
}

