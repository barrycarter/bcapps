#!/bin/perl

# Given a stream of text (eg, the first billion digits of pi), create
# frames of size 1280x720 using fly's "tiny" font mode, which is 5x8, so
# 256 char per line, 90 lines per frame, or 23040 characters per frame,
# thus 552960 characters per second, 33177600 characters per minute

# consider going to the one resolution below 1280x720

require "/usr/local/lib/bclib.pl";

my($buf);

# the 22 Kelly colors of maximum contrast, hex form
# https://gist.github.com/ollieglass/f6ddd781eeae1d24e391265432297538

# note: intentionally deleted "222222" from $kelly[1] position (2nd
# element), since I want to use black as my background, and 222222 is
# close

@kelly = ('F2F3F4', 'F3C300', '875692', 'F38400', 'A1CAF1',
'BE0032', 'C2B280', '848482', '008856', 'E68FAC', '0067A5', 'F99379',
'604E97', 'F6A600', 'B3446C', 'DCD300', '882D17', '8DB600', '654522',
'E25822', '2B3D26');

# converted to fly format ("$r,$g,$b" as string)

for $i (@kelly) {
  $i=~/^(..)(..)(..)$/||die("BAD COLOR: $i");
  $i = join(",", hex($1), hex($2), hex($3));
}

# silly values to force instant new frame
($y, $f) = (720,-1);

while (sysread(STDIN, $buf, 256)) {

  # new frame?
  if ($y==720) {
    close(A);
    $f = sprintf("%09d", $f+1);
    $y=0;
    open(A, ">frame$f.fly");
#    print A "new\nsize 1280,720\nsetpixel 0,0,255,255,255\n";
    print A "new\nsize 1280,720\nsetpixel 0,0,0,0,0\n";
  }

  for ($x=0; $x<1280; $x+=5) {
    my($char) = substr($buf,$x/5,1);
    print A "string $kelly[$char],$x,$y,tiny,$char\n";
  }

#  print A "string 255,0,0,0,$y,tiny,$buf\n";
  $y+=8;

  debug("GOT: $buf");
}


=item comment

from https://www.math.cornell.edu/~mec/2003-2004/cryptography/subs/frequencies.html letter frequencies

E 21912   E 12.02
T 16587   T 9.10
A 14810   A 8.12
O 14003   O 7.68
I 13318   I 7.31
N 12666   N 6.95
S 11450   S 6.28
R 10977   R 6.02
H 10795   H 5.92
D 7874   D 4.32
L 7253   L 3.98
U 5246   U 2.88
C 4943   C 2.71
M 4761   M 2.61
F 4200   F 2.30
Y 3853   Y 2.11
W 3819   W 2.09
G 3693   G 2.03
P 3316   P 1.82
B 2715   B 1.49
V 2019   V 1.11
K 1257   K 0.69
X 315   X 0.17
Q 205   Q 0.11
J 188   J 0.10
Z 128   Z 0.07

assign 21 colors (minus whatever I choose as bg) as follows: 20 to 20 most popular letters, 21 to remaining 6

=cut

# TODO: use letter freqs when doing text and maybe do wrap to 256 chars

# TODO: generalize code a bit, too ugly and overly tight
