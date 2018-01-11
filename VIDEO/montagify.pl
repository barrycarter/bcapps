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

# list of frames for ffmpeg
open(B,">$targetdir/MONTAGE/frames.txt");

for $i (sort keys %hash) {
  for $j (sort keys %{$hash{$i}}) {
    debug("MONTAGE: $i, FRAME: $j");
    my(@frames) = ();
    for $k ("0001".."0025") {

      # ffmpeg needs absolute frame numbers, so we symlink these
      $absframe = sprintf("%09d", $absframe+1);

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
    push(@cmds, "montage -geometry $geom -tile 5x5 $frames $targetdir/MONTAGE/M${i}F${j}.jpg");
    print B "$targetdir/MONTAGE/M${i}F${j}.jpg\n";

  }
}

close(B);
open(A, ">$targetdir/MONTAGE/commands.sh");
print A join("\n",@cmds),"\n";
close(A);

die "TESTING";



# thin wrapper around montage

# Given a list of directories on the stdin that presumably have frame
# JPGs in them, create 5x5 montages, but using a blank frame so that
# each "episode" in the directory maintains its place


# this is 1/5th in each dir

my(@vids) = ();

while (<>) {

  chomp;

  unless (-d $_) {
    die("$_ is file, not directory (perhaps pipe from 'ls -d', not 'ls'?)");
  }

  # TODO: make this more flexible
  push(@vids, $_);

  if (scalar(@vids) == 25) {
    process_vids(@vids);
    @vids = ();
    next;
  }
}

sub process_vids {
  my(@vids) = @_;
  my($count) = 0;
  debug("GOT",@vids);

  # the number of montage images we need (one for each 25 episodes)
  $montage++;

  # TODO: the name of the montage file MUST be user controllable
  my($mfile) = "montage";

  # this loop ends when we run out of frames on all files
  while (++$count) {

    # TODO: this is ugly, use alt var?
    $count = sprintf("%08d",$count);

    my(@frames) = ();
    my($filecount) = 0;

    # this is seriously inefficient?
    for $i (@vids) {

      # filename for this montaged frame
      my($fname) = "$i/${i}_$count.jpg";

      # if the file exists for a given episode, push it + count it
      if (-f $fname) {
	$filecount++;
	push(@frames, "$i/${i}_$count.jpg");
      } else {
	# TODO: choose a much better filler, eg something mentioning me
	push(@frames, "filler.png");
      }
    }

    # if no files left (except filler), return
    if ($filecount==0) {return;}

    my($frames) = join(" ",@frames);

    my($cmd) = "montage -geometry $geom -tile 5x5 $frames $mfile-$montage-$count.jpg";

    print "$cmd\n";
  }
}

=item comments

Sample command:




=cut
