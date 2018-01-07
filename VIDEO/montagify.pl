#!/bin/perl

# thin wrapper around montage

# Given a list of directories on the stdin that presumably have frame
# JPGs in them, create 5x5 montages, but using a blank frame so that
# each "episode" in the directory maintains its place

require "/usr/local/lib/bclib.pl";

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
