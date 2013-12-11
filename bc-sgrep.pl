#!/bin/perl

# does what sgrep does (looks for data in a sorted file), but
# hopefully works better (and adds options)

require "/usr/local/lib/bclib.pl";
# TODO: this can do bad things if locale changes from sort to bc-sgrep.pl
use locale;

# TODO: allow multiple files
# TODO: allow specification of how file is sorted (currently assumed default)
# TODO: handle corner case of where first/last line matches
# TODO: show all matches not just first found
# TODO: in case of fail, show bracketing lines
my($key, $file) = @ARGV;

$size = -s $file;
($l, $r) = (0, $size);
open(A,$file);

for (;;) {
  # fail condition
  if (abs($l-$r)<=1) {
    debug("FAIL");
    last;
  }

  # look between left and right
  $seek = round(($l+$r)/2);
  seek(A, $seek, SEEK_SET);
  # get current line
  $line = current_line(\*A,"\n");

  # if it matches, exit (will print later)
  # TODO: case insensitivity should be optional
  if (lc(substr($line,0,length($key))) eq lc($key)) {last;}

  # if not, change left/right range
  # TODO: generalize this test
  if (lc($key) lt lc($line)) {
    $r = $seek;
  } else {
    $l = $seek;
  }

  debug("$l - $r ($seek), $line, $n");
}

# remember where we are
my($pos) = tell(A);

# look at lines going forward
do {
  $line = current_line(\*A, "\n");
  push(@for, $line);
} until (lc(substr($line,0,length($key))) ne lc($key));

# reset to original position
seek(A,$pos,SEEK_SET);

# look at lines going backwards
do {
  $line = current_line(\*A, "\n",-1);
  push(@rev, $line);
} until (lc(substr($line,0,length($key))) ne lc($key));

debug("FOR",@for);
debug("REV",@rev);
