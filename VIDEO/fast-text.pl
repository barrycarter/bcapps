#!/bin/perl

# Given a stream of text (eg, the first billion digits of pi), create
# frames of size 1280x720 using fly's "tiny" font mode, which is 5x8, so
# 256 char per line, 90 lines per frame, or 23040 characters per frame,
# thus 552960 characters per second, 33177600 characters per minute

require "/usr/local/lib/bclib.pl";

my($buf);

# the 22 Kelly colors of maximum contrast, hex form
# https://gist.github.com/ollieglass/f6ddd781eeae1d24e391265432297538

@kelly = ('F2F3F4', '222222', 'F3C300', '875692', 'F38400', 'A1CAF1',
'BE0032', 'C2B280', '848482', '008856', 'E68FAC', '0067A5', 'F99379',
'604E97', 'F6A600', 'B3446C', 'DCD300', '882D17', '8DB600', '654522',
'E25822', '2B3D26');

# converted to fly format ("$r,$g,$b" as string)

for $i (@kelly) {
  $i=~/^(..)(..)(..)$/||die("BAD COLOR: $i");
  $i = join(",", hex($1), hex($2), hex($3));
}

debug(@kelly);

# TODO: actually use Kelly color (char per char)

# silly values to force instant new frame
($y, $f) = (720,-1);

while (sysread(STDIN, $buf, 256)) {

  # new frame?
  if ($y==720) {
    close(A);
    $f++;
    $y=0;
    open(A, ">frame$f.fly");
    print A "new\nsize 1280,720\nsetpixel 0,0,255,255,255\n";
    if ($f>2) {die "TESTING";}
  }

  print A "string 255,0,0,0,$y,tiny,$buf\n";
  $y+=8;

  debug("GOT: $buf");
}


=item comment

Numbers to colors (white is bg so excluded, unless I go grey?):

basic 3:

red green blue

combines:

yellow cyan purple

no, using kellys https://hackerspace.kinja.com/some-os-x-calendar-tips-1658107833/1665644975

white 


=cut
