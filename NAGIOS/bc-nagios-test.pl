#!/bin/perl

# Runs a nagios test; if a plugin exists, use it; otherwise, use
# subroutines defined here

push(@INC,"/usr/local/lib");

# this is hideous; pass args to the program using NAGIOS_ARG2
@ARGV = split(/\s+/, $ENV{NAGIOS_ARG2});

require "bclib.pl";

# what are we being asked to run?
my($cmd) = $ENV{NAGIOS_ARG1};

# split into command and arguments (removing quotes first)
$cmd=~s/\"//isg;
$cmd=~/^\s*(.*?)\s+(.*)$/;
my($bin,$arg) = ($1,$2);

# TODO: allow for non-plugin runs (at which point splitting bin and
# arg will make sense
# >>8 converts Perl exit value to program exit value (kind of)
$res = system("$bin $arg")>>8;

# run function on result before returning?
if ($globopts{func}) {$res = func($globopts{func}, $res);}

# this is ugly, but works (spits out stuff to console)
# TODO: redirect output of nagios to file that should remain empty
print STDERR "FUNC: $globopts{func}, RES: $res\n";

exit($res);

=item func($func, $val)

Applies $func to $val, where func is a very simple function.

Used primarily to turn return values of 1 to 0 when needed

=cut

sub func {
  my($func,$val) = @_;

  # when I want grep to fail, 1 is good, other values are bad
  # (values like 2 indicate other problems that I do need to be aware of
  if ($func eq "1is0") {
    if ($val==1) {return 0;}
    if ($val==0) {return 2;}
    return $val;
  }

  # some scripts return '1' to mean bad, but I want to return 2
  if ($func eq "1is2") {
    if ($val==1) {return 2;}
    return $val;
  }

}

