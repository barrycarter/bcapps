#!/bin/perl -n

# trivial script to turn srt files back into readable files

# coursera.org offers many free courses, but many of the lectures are
# professors with audio/video of them speaking text, perhaps the most
# inefficient use of bandwidth ever

# this gets to the heart of what you're actually learning (although
# some profs tend to ramble on), so you only watch videos when they're
# useful (which is rarely)

# the only benefit of an RL classroom is interaction with the
# professor and other students; moocs take away that one benefit

# ignore blank lines

if (/^\s*$/) {
#  print "STOPPED: $_\n";
 next;
}

if (/^[\r\s\d:,\->]*$/) {
#  print "STOPPED: $_\n";
  next;
}

print $_;
