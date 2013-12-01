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
  if (abs($l-$r)<=1) {last;}

  # look between left and right
  $seek = round(($l+$r)/2);
  seek(A, $seek, SEEK_SET);
  # discard remainder of this line and pick next line
  # TODO: this doesn't actually do what I think it does
  <A>;
  $line = <A>;

  # if it matches, exit
  if (substr($line,0,length($key)) eq $key) {last;}

  # if not, change left/right range
  if ($key lt $line) {
    $r = $seek;
  } else {
    $l = $seek;
  }

  debug("$l - $r ($seek), $line, $n");
  if ($n++ > 30) {die "TESTING";}
}

print $line;

=item find_newline(\*A, $whence)

Seeks filehandle A to a newline; the next newline if $whence=1, the
previous newline if $whence=-1

Will seek to start/end of file if there are no newlines in the
indicated direction

=cut

sub find_newline {
  my($fh, $whence) = @_;
  debug("FH: $fh");
}


