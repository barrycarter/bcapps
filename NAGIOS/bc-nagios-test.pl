#!/bin/perl

# Runs a nagios test; if a plugin exists, use it; otherwise, use
# subroutines defined here

push(@INC,"/usr/local/lib");

# this is hideous; pass args to the program using NAGIOS_ARG2
@ARGV = split(/\s+/, $ENV{NAGIOS_ARG2});

require "bclib.pl";

# for testing only!
$globopts{debug}=1;

# what are we being asked to run?
my($cmd) = $ENV{NAGIOS_ARG1};

# split into command and arguments (removing quotes first)
$cmd=~s/\"//isg;
$cmd=~/^\s*(.*?)\s+(.*)$/;
my($bin,$arg) = ($1,$2);

# if the "binary" starts with "bc_", I want to run a local function
if ($bin=~/^bc_/) {
  # this is dangerous, but I control my nagios files
  $res = eval($cmd);
  debug("$cmd returns: $res");
  # below just for testing
  exit($res);
}

# >>8 converts Perl exit value to program exit value (kind of)
$res = system("$bin $arg")>>8;

# run function on result before returning?
# no need to do this on functions I write myself, above
if ($globopts{func}) {$res = func($globopts{func}, $res);}

# this is ugly, but works (spits out stuff to console)
# TODO: redirect output of nagios to file that should remain empty
# debug("FUNC: $globopts{func}, RES: $res");

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

=item bc_nagios_file_size($file, $size, $options)

Confirm that $file (which can be a directory) is less than $size
bytes; $options currently unused

=cut

sub bc_nagios_file_size {
  my($file, $size, $options) = @_;
  my($stat) = `/usr/local/bin/stat $file | fgrep Size:`;
  $stat=~/Size:\s+(\d+)\s/;
  $stat=$1;
  debug("SIZE: $stat");
  if ($stat > $size) {return 2;}
  return 0;
}



