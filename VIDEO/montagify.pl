#!/bin/perl

# thin wrapper around montage

# Given a list of directories on the stdin that presumably have frame
# JPGs in them, create 5x5 montages, but using a blank frame so that
# each "episode" in the directory maintains its place

require "/usr/local/lib/bclib.pl";

# TODO: allow this to vary?

my($geom) = "1280x720";

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
  debug("GOT",@vids);

  # the number of montage images we need (one for each 25 episodes)
  $montage++;

  # this loop ends when we run out of frames on all files
  while (++$count) {

    # TODO: this is ugly, use alt var?
    $count = sprintf("%08d",$count);

    my(@frames) = ();

    # this is seriously inefficient?
    for $i (@vids) {
      push(@frames, "$i/${i}_$count.jpg");
    }

    my($frames) = join(" ",@frames);

    my($cmd) = "montage -geometry $geom -tile 5x5 $frames output.jpg";

    print "$cmd\n";

    die "TESTING";

    debug("FRAMES",@frames);


#    debug("COUNT: $count");
  }

}

=item comments

Sample command:




=cut
