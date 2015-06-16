#!/bin/perl

# Usage: $0 directory-where-mod-is (last part of dir will be used as map name)

# A direct attempt at creating maps for Dink D-Mods

require "/usr/local/lib/bclib.pl";

my($moddir) = @ARGV;

# since I'm going to chdir to another dir, need moddir
unless ($moddir=~m%^/%) {$moddir = "$ENV{PWD}/$moddir";}

# and name
$name = $moddir;
$name=~s%^.*/%%;
unless ($name) {die "Usage: $0 <directory> [cannot use current dir + dir name can't end in slash]";}

# maps created here
system("mkdir -p /usr/local/etc/DINK/MAPS/$name");
dodie('chdir("/usr/local/etc/DINK/MAPS/$name")');

my(%dinksprites) = read_dink_ini();

# TODO: allow map.dat to be in different dir
# how many screens?
my($ns) = int((-s "$moddir/map.dat")/31280);
open(A,"$moddir/map.dat")||die("Can't open $moddir/map.dat");
my($buf);

for $i (0..$ns-1) {
  debug("SCREEN $i");
  seek(A,31280*$i,SEEK_SET);
  read(A,$buf,31820);
  dink_render_screen($buf,"screen$i.png");
  dink_sprite_data($buf,"screen$i.png");
  die "TESTING";
}

# Given the 31820 byte chunk representing a screen, attempt to recreate screen in given filename

sub dink_render_screen {
  my($data,$file) = @_;

  if (-f $file) {return;}

  # need better output convention
  local(*A);
  open(A,"|montage \@- -tile 12x8 -geometry +0+0 $file");

  # the tiles
  for $y (1..8) {
    for $x (1..12) {
      $data=~s/^.{20}(.)(.)(.{58})//s;
      # tile number and screen number (wraparound if $t>=128)
      my($t,$s) = (ord($1),2*ord($2)+1);
      if ($t>=128) {$s++; $t=-128;}
      # top left pixel
      my($px,$py) = ($t%12*50,int($t/12)*50);
      # TODO: fix ts*.bmp case oddnesses
      # TODO: look for tiles in game itself, not just stdloc
      # create if not already existing
      unless (-f "/var/cache/DINK/tile-$s-$px-$py.png") {
	my($fname) = sprintf("/usr/share/dink/dink/Tiles/Ts%02d.bmp",$s);
	unless (-f $fname) {die "NO SUCH FILE: $fname";}
	my($out,$err,$res) = cache_command2("convert -crop 50x50+$px+$py $fname /var/cache/DINK/tile-$s-$px-$py.png");
      }
      print A "/var/cache/DINK/tile-$s-$px-$py.png\n";
    }
  }
  close(A);
}

# given an image, determine sprite data and overlay it onto image

sub dink_sprite_data {
  my($data,$image) = @_;
  my(@sprites);

  # sprite data starts at 8020, but first sprite is always blank
  $data=~s/^.{8240}//s;

  # 100 sprites
  my($count) = 0;

  while ($data=~s/^(.{220})//s) {
    if (++$count>100) {last;}
    my($sprite) = $1;
    # silently ignore null
    if ($sprite=~/^\0+$/) {next;}
    my(@sprite);
    while ($sprite=~s/^(....)//s) {push(@sprite,unpack("i4",$1));}

    debug("SPRITE DATA",@sprite);
    # xpos = 4 char, ypos = 4 char, seq = 4 char, frame = 4 char, type/size?
    # TODO: ignoring frame number for now, just putting 01 frame
    # TODO: ignoring size for now
    my($xpos, $ypos, $seq, $frame, $type, $size, $active, $rotation, $special, $brain) = @sprite;
    $frame = sprintf("%0.2d", $frame);
    my($fname) = "$bclib{githome}/DINK/PNG/$dinksprites{$seq}$frame.PNG";

    # not so silently ignore non sprites
    unless (-f $fname) {
      warn "SPRITE $seq,$frame, $dinksprites{$seq} does not exist, ignoring";
      next;
    }

    # TODO: this is only a test!
    $xpos-=100;
    $ypos-=100;

    push(@sprites, "-page +$xpos+$ypos $fname");
    debug("$fname to $xpos,$ypos")
  }

  my($sprites) = join(" ",@sprites);
  my($out,$err,$res) = cache_command2("convert -page +0+0 $image $sprites -layers flatten temp-$image");
}

# reads the standard Dink.ini file (not mod-specific), returns a
# number-to-sprite-hash

sub read_dink_ini {
  my(%result);
  my(@lines) = `fgrep load_sequence /usr/share/dink/dink/Dink.ini`;

  for $i (@lines) {
    $i=~/^.*\\(.*?)\s+(\d+)/;
    $result{$2} = uc($1);
  }
  return %result;
}


