#!/bin/perl

# Given a list of videos on the STDIN, ultimately creates a video that
# shows 25 subvideos per screen at 24 times the regular speed

require "/usr/local/lib/bclib.pl";

# get the name and create a subdir to store files
my($name) = @ARGV;
unless ($name) {die "Usage: $0 name";}
if ($#ARGV > 0) {die "ERROR: exactly one argument required";}
my($targetdir) = "$bclib{home}/VIDEOFRAMES/$name";
unless (-d $targetdir) {dodie("mkdir('$targetdir')");}
# TODO: this is an awful way to make <> now be STDIN
@ARGV = ();

# TODO: make this flexible?
my($size) = "256:144";

open(A, ">$targetdir/rip.sh")||die("Can't open rip.sh, $!");

# the commands I will run (or at least print)
my(@cmds);

# TODO: require an existing subdir for writing

# montage = one for every 25 videos (M)
# video = one for every video (V)
# frame = one for every second of every video (F)

my($montage);
my($video);

my($out, $err, $res);

while (<>) {

  chomp;

  unless (-f $_) {die "STDIN: $_ is not a file";}

  # if 25 limit (or first run), reached, next montage
  if ($video%25 == 0) {
    $montage = sprintf("%08d",++$montage);
    $video = 0;
  }

  # increment video, but keep in %04d form
  $video = sprintf("%04d",++$video);


  # break this video in "one second" chunks (assuming 24 frames = one second)
  # TODO: better way to do this w/o assuming it's 24 fps?
  push(@cmds, qq{ffmpeg -i "$_" -vf "select=not(mod(n\\,24)), scale=$size" -vsync vfr $targetdir/M${montage}V${video}F%08d.jpg});

}

print A join("\n", @cmds),"\n";
close(A);



die "TESTING";


# thin wrapper around montage

# Given a list of directories on the stdin that presumably have frame
# JPGs in them, create 5x5 montages, but using a blank frame so that
# each "episode" in the directory maintains its place

# TODO: allow this to vary?

# this is 1/5th in each dir
my($geom) = "256x144";

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
