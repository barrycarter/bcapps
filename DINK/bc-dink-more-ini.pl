#!/bin/perl

# "completes" the Dink.ini file by creating SET_SPRITE_INFO lines for
# missing sprites per http://www.dinknetwork.com/forum.cgi?MID=192108

require "/usr/local/lib/bclib.pl";

# read existing sprite info from Dink.ini
my(@sinfo) = `fgrep SET_SPRITE_INFO /usr/share/dink/dink/Dink.ini`;

my(%haveinfo);
for $i (@sinfo) {
  my($x,$s,$f) = split(/\s+/, $i);
  $haveinfo{"$s.$f"} = 1;
}

for $i (split(/\n/,read_file("$bclib{githome}/DINK/dink-sequences.txt"))) {
  my($num,$file) = split(/\s+/, $i);
  $file=~s%^.*\\%%;
  $file=uc($file);
  my(@frames) = glob("$bclib{githome}/DINK/PNG/$file\[0-9\]\[0-9\]\.PNG");

  # MOUND- is the only case w/o frames now
  unless (@frames) {warn "$num/$file has no frames"; next;}

  for $j (@frames) {
    unless ($j=~/\D(\d\d)\.PNG$/) {warn "BAD FILE: $j"; next;}
    my($frame) = $1;
    $frame=~s/^0//;
    # do we have info on this frame? if so, skip
    if ($haveinfo{"$num.$frame"}) {next;}

    # image x/y sizes
    my($out,$err,$res) = cache_command2("identify $j","age=86400");
    unless ($out=~/\s+(\d+)x(\d+)\s+/) {warn "BAD LINE: $j $out"; next;}
    my($xs,$ys) = ($1,$2);

    # compute the 6 numbers
    my(@nums) =
      ($xs-int($xs/2)+int($xs/6), $ys-int($ys/4)-int($ys/30),
       -int($xs/4), -int($ys/10), int($xs/4), int($ys/10));

    print "SET_SPRITE_INFO $num $frame ",join(" ",@nums),"\n";
  }
}


