#!/bin/perl

# Usage: $0 directory-where-mod-is (last part of dir will be used as map name)

# A direct attempt at creating maps for Dink D-Mods

require "/usr/local/lib/bclib.pl";

# the 4-byte integers at the start of a sprite (before the 14 character script)

my(@sdata) = ("xpos", "ypos", "seq", "frame", "type", "size",
"active", "rotation", "special", "brain");

# the 4-byte integer field that appear after script name + 38 unused chars

my(@smore) = ("speed", "base_walk", "base_idle", "base_attack",
"base_hit", "timer", "que", "hard", "alt.left", "alt.top",
"alt.right", "alt.bottom", "prop", "warp_map", "warp_x", "warp_y",
"parm_seq", "base_die", "gold", "hitpoints", "strength", "defense",
"exp", "sound", "vision", "nohit", "touch_damage");

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
  debug("SCREEN $i\n\n");
  seek(A,31280*$i,SEEK_SET);
  read(A,$buf,31820);
  dink_render_screen($buf,"screen$i.png");
  dink_sprite_data($buf,"screen$i.png");
  if ($i>10) {die "TESTING";}
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
    if ($sprite=~/^\0+$/) {
      debug("SPRITE $count: NULL\n");
      next;
    }

    my(%sprite);

    for $i (@sdata) {
      $sprite=~s/(.{4})//s;
      $sprite{$i} = unpack("i4",$1);
    }

    # 14 character script to run
    $sprite=~s/^(.{14})//s;
    $sprite{"script"} = $1;

    # 38 unused characters
    $sprite=~s/^.{38}//s;

    for $i (@smore) {
      $sprite=~s/(.{4})//s;
      $sprite{$i} = unpack("i4",$1);
    }

    # if not in vision 0, ignore
    if ($sprite{vision}) {next;}

    # for filenaming
    $sprite{frame} = sprintf("%0.2d", $sprite{frame});

    # from Dink.ini
    $sprite{"extra"} = $dinksprites{"$sprite{seq}.$sprite{frame}"};

    # this is just for debugging (for now)
    $sprite{"fname"} = "$bclib{githome}/DINK/PNG/$dinksprites{$sprite{seq}}$sprite{frame}.PNG";

    unless (-f $sprite{fname}) {
      warn "NO SUCH FILE: $sprite{fname}, ignoring";
      next;
    }

    $sprite{"more"} = $dinksprites{"$sprite{seq}.extra"};

    debug("SPRITE: $count\n");
    for $i (sort keys %sprite) {
      debug("$i: $sprite{$i}");
    }
    debug();

    # figure out true x y coords

    if ($sprite{"extra"}) {
      # keeping these as two separate keys, easier to debug
      ($sprite{xdelta},$sprite{ydelta}) = split(/\s+/, $sprite{extra});
      $sprite{deltamethod} = "dink.ini";
    } else {
      # per http://www.dinknetwork.com/forum.cgi?MID=192179
      my(@res) = cache_command2("identify $fname","age=86400");
      $res[0]=~s/.*?(\d+)x(\d+)//;
      $sprite{deltamethod} = "formula";
      $sprite{xdelta} = int($1/6)-int($1/2);
      $sprite{ydelta} = -int($2/4)-int($2/30);
    }

    $sprite{xpos}+=$sprite{xdelta};
    $sprite{ypos}+=$sprite{ydelta};

    push(@sprites, "-page +$sprite{xpos}+$sprite{ypos} $sprite{fname}");
  }

  my($sprites) = join(" ",@sprites);
  my($out,$err,$res) = cache_command2(transdebug("convert -page +0+0 $image $sprites -layers flatten temp-$image"));
}

sub transdebug {debug(@_); return @_;}

# reads the standard Dink.ini file (not mod-specific), returns a
# number-to-sprite-hash with additional sprite info

sub read_dink_ini {
  my(%result);
  my(@lines) = split(/\n/, read_file("/usr/share/dink/dink/Dink.ini"));

  for $i (@lines) {
    if ($i=~m%^load_sequence(_now)?\s+.*\\(.*?)\s+(\d+)(.*)$%) {
      $result{$3} = uc($2);
      $result{"$3.extra"} = $4;
    } elsif ($i=~/^SET_SPRITE_INFO\s+(\d+)\s+(\d+)\s+(.*)$/) {
      $result{"$1.$2"} = $3;
    } else {
      # do nothing
    }
  }
  return %result;
}


