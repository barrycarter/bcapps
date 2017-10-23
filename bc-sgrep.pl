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
# TODO: confirm file is sorted, to extent possible (w/o doing extra work)
my($key, $file) = @ARGV;
my(%data);

debug("FILE: $file");

$size = -s $file;
($l, $r) = (0, $size);
open(A,$file);

for (;;) {
  # fail condition
  if (abs($l-$r)<=1) {
    # TODO: decide on die vs debug here
    debug("FAILED"); exit(1);
#    die "FAILED";
  }

  # look between left and right
  $seek = round(($l+$r)/2);
  seek(A, $seek, SEEK_SET);
  # get current line
  $line = current_line(\*A,"\n");
  # TODO: confirm data keys and values in same order (else, badly sorted input)
  $data{$seek} = $line;
  debug("SEEK: $seek, LINE: $line");

  # if it matches, exit (will print later)
  # TODO: case insensitivity should be optional
  if (substr($line,0,length($key)) eq $key) {last;}

  # if not, change left/right range
  # TODO: generalize this test
  if ($key lt $line) {
    $r = $seek;
  } else {
    $l = $seek;
  }

#  debug("$l - $r ($seek), $line, $n");
}

# move back two positions so we are just before newline
# TODO: not crazy about code logic here; fix current_line()?
my($pos) = max(tell(A)-2,0);

# look at lines going forward
while (substr($line,0,length($key)) eq $key) {
  chomp($line);
  push(@for, $line);
  $line = current_line(\*A, "\n");
}

debug("FOR FAIL: $line");

# reset to original position
seek(A,$pos,SEEK_SET);
$line = current_line(\*A,"\n",-1);

# look at lines going backwards
while  (substr($line,0,length($key)) eq $key) {
  chomp($line);
  push(@rev, $line);
  $line = current_line(\*A, "\n",-1);
}

debug("REV FAIL: $line");

# print the lines (@rev in reverse order to preserve sorting)
print join("\n",reverse(@rev)),"\n";
print join("\n",@for),"\n";

# TODO: the original found $line will be repeated sometimes, fix
# debug("FOR",@for);
# debug("REV",@rev);
