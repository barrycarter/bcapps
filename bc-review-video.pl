#!/bin/perl

# Plays given video files, and allows me to mark them "watched", "bad"
# (cannot be played), etc

require "/usr/local/lib/bclib.pl";
# where to store info (location is temporary for now)
my($statfile) = "/home/barrycarter/20131116/video-status.txt";

# ignore files already noted
my($data) = read_file($statfile);
for $i (split(/\n/, $data)) {
  # ignore status
  $i=~s/^\S+\s//;
  $decided{$i} = 1;
}

for $i (@ARGV) {
  # require full path, but don't display it
  unless ($i=~/^\//) {
    warn ("NOT FULL PATH, IGNORING: $i");
    next;
  }

  $disp = $i;
  $disp=~s/^.*\///;

  if ($decided{$i}) {
    warn("STATUS($disp) already determined, skipping");
    next;
  }

  $rep = get_response("PLAY?: $disp");

  # TODO: allow file rating without mandatory watch
  if ($rep=~/^y$/i) {
    # fork to allow me to kill later (could also use pkill -f)
    $child = fork();
    # if I am the child, just vlc and exit
    unless ($child) {
      exec("vlc \"$i\" >& /dev/null");
    }
  } else {
    print "Skipping...\n";
    next;
  }

  $rep = get_response("(W)atched|(B)ad|(T)owatch list?");
  debug("KILLING: $child");
  system("kill $child");

  if ($rep=~/^w$/i) {
    append_file("WATCHED $i\n",$statfile);
  } elsif ($rep=~/^t$/i) {
    append_file("TOWATCH $i\n",$statfile);
  } elsif ($rep=~/^b$/i) {
    append_file("BAD $i\n",$statfile);
  } else {
    print "$rep not understood, moving on\n";
  }
}

=item get_response($string)

Print $string and return user response, but disallow empty response;
die if no answer after 10 prompts

TODO: allow caller to customize what strings are acceptable and how
many times to wait before dieing; and also whether to die or simply return 0

=cut

sub get_response {
  my($string) = @_;
  my($rep);
  my($count);
  do {
    print "$string\n";
    $count++;
    $rep = <STDIN>;
  } until ($rep=~/\S/ || $count>10);
  if ($rep=~/\S/) {return $rep;}
  die "NO REPLY AFTER 10 TRIES";
}


