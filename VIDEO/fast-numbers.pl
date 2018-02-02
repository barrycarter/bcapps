#!/bin/perl

# Given a stream of numbers (eg, the first billion digits of pi), create
# frames of size 1280x720 using fly's "tiny" font mode, which is 5x8, so
# 256 char per line, 90 lines per frame, or 23040 characters per frame,
# thus 552960 characters per second, 33177600 characters per minute

# see also https://en.wikipedia.org/wiki/List_of_common_resolutions
# below per https://www.h3xed.com/web-and-internet/youtube-recommended-video-resolutions-for-quality-and-search-optimization

# 3840x2160 2160p
# 2560x1440 1440p
# 1920x1080 1080p
# 1280x720 720p = 33177600/minute
# 854x480 480p = 14757120/minute (about twice as big though)
# 640x360 360p
# 426x240 240p

require "/usr/local/lib/bclib.pl";

# TODO: this is temporary workdir
chdir("/home/user/20180127");

# TODO: consider lower resolution later

my($xsize, $ysize) = (1280, 720);

# font size (TODO: consider using different font later)
# TODO: consider using proportional font, but maybe icky

my($font) = "tiny";
my($fx, $fy) = (5, 8);

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

# precompute characters per line, lines per page

# TODO: confirm these are ints, otherwise problems

my($cpl, $lpp) = ($xsize/$fx, $ysize/$fy);

# pi-billion.txt happens to be a single line 1GB, hope this works!
# takes about 3.3 seconds, so ok

my($data, $file) = cmdfile();

# compute number of frames

my($nframes) = length($data)/$cpl/$lpp;

debug("Frames: $nframes", "Seconds: ".$nframes/24, "Minutes: ".$nframes/24/60);

for ($f=0; $f<=$nframes; $f++) {

  if ($f>10) {die "TESTNG";}

  # new frame
  my($name) = sprintf("%09d", $f);

  # this is really bad
  open(A, "|fly -q|convert - frame$name.png");

  # image header
  print A "new\nsize $xsize,$ysize\n";

  # setpixel sets bgcolor
  print A "setpixel 0,0,0,0,0\n";

  for ($y=0; $y<$lpp; $y++) {

    # compute y position

    my($ypos) = $y*$fy;

    for ($x=0; $x<$cpl; $x++) {

      # and xpos
      my($xpos) = $x*$fx;

      # and print (advance character counter for next time)
      my($print) = substr($data, $char++, 1);
      debug("PRINT: $print");

      # and color (for text, will need hash, not array)
      my($color) = $kelly[$print];

      # TESTING here so I can confirm I am printing all chars
      # NOTE: I don't initalize testprint, but ok, temp var
#      $testprint = ($testprint+1)%10;
#      $print = $testprint;

      # TODO: the "." gets lost below, not sure I care ($kelly[.] not defined)
      # and print
      my($str) = "string $kelly[$print],$xpos,$ypos,$font,$print";
      debug("PRINTING: $str");
      print A "$str\n";

#      debug("$xpos, $ypos, $name");

    }
  }

  close(A);

}

die "TESTING";

# TODO: escape out of loop if I reach frame limit

for ($i=0; $i<length($data); $i++) {
  my($char) = substr($data, $i, 1);
  debug("CHAR: $char");
}


die "TESTING";

my($buf);

# converted to fly format ("$r,$g,$b" as string)

# determine 

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
