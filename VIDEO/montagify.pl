#!/bin/perl

# selectively rips a video (one frame per second) to display it faster

require "/usr/local/lib/bclib.pl";

# make sure the ripped frames exist (or at least their dir)

my($name) = @ARGV;
unless ($name) {die "Usage: $0 name";}
if ($#ARGV > 0) {die "ERROR: exactly one argument required";}
my($targetdir) = "$bclib{home}/VIDEOFRAMES/$name";
unless (-d $targetdir) {die "TARGETDIR $targetdir does not exist";}

# will put the montage in this subdir
unless (-d "$targetdir/MONTAGE") {dodie("mkdir('$targetdir/MONTAGE')");}
# TODO: allow this to vary?
my($geom) = "256x144";

# see files in dir to determine how many montages and max frames for
# each montage

my(%hash);

# TODO: add sanity checking here?

my(@files) = `ls $targetdir`;

# debug("FILES", @files);

for $i (@files) {

  chomp($i);

  # ignore shell files and the MONTAGE dir itslef
  if ($i=~/\.sh$/ || $i eq "MONTAGE") {next;}

  # specific format required
  unless ($i=~/^M(\d{8})V(\d{4})F(\d{8})\.jpg$/) {die "BAD FILE: $i";}
  my($m, $v, $f) = ($1,$2,$3);
  # note that $v will always run from 1-25
  $hash{$m}{$f} = 1;
}

# the commands I will run, possibly in parallel
my(@cmds);

# and now, the frame by frame montages

for $i (sort keys %hash) {
  for $j (sort keys %{$hash{$i}}) {
    debug("MONTAGE: $i, FRAME: $j");
    my(@frames) = ();

    # ffmpeg needs absolute frame numbers, so we symlink these
    # TODO: this is icky, can I use $absframe++ somehow? (perl magic?)
    $absframe = sprintf("%09d", $absframe+1);

    for $k ("0001".."0025") {

      my($fname) = "$targetdir/M${i}V${k}F$j.jpg";
#      debug("FNAME: $fname");

      if (-f $fname) {
	push(@frames, $fname);
      } else {
	# TODO: make blank frames more interesting? (ie, rotation?)
	push(@frames, "$bclib{home}/VIDEOFRAMES/blank.jpg");
      }
    }

    my($frames) = join(" ",@frames);
    push(@cmds, "/usr/bin/nice -n 19 montage -geometry $geom -tile 5x5 $frames $targetdir/MONTAGE/M${i}F${j}.jpg");
    push(@cmds, "ln -s $targetdir/MONTAGE/M${i}F${j}.jpg $targetdir/MONTAGE/frame$absframe.jpg");
  }
}

open(A, ">$targetdir/MONTAGE/commands.sh");
print A join("\n",@cmds),"\n";
print A "xmessage $0 has finished\n";
close(A);

=item comments

10681.701u 348.888s 34:37.90 530.8%     0+0k 4377776+5661984io 12021pf+0w

to montage 5 seasons of Muppets

16105.041u 1150.829s 15:18.77 1878.1%   0+0k 4532400+9736120io 78pf+0w

to montage 5 seasons using parallel -j 20

=cut
