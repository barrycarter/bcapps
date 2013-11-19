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
# print <A>;
# print <A>;
# print <A>;

=item unixsort(\@l, $options)

Return the Unix sort of @l under given $options.

Unix sorts differently than Perl (sometimes)

=cut

sub unixsort {
  my($listref, $options) = @_;
  # TODO: write this function
}
