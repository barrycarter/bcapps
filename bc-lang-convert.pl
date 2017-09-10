#!/bin/perl

# attempts to convert a formula into many different languages

# TODO: rename this rosetta or is that overdone?

require "/usr/local/lib/bclib.pl";

# code gets stored here
my(@code);

# hardcoded for now

# this is from bc-rst.m

$fname = "HADecLat2azEl";

@vars = ("ha", "dec", "lat");

$vars = join(", ",@vars);

$desc = "This is a test function that does nothing useful... unless you consider testing useful... then it does something useful... but not useful to you... unles you're testing with me";

$form = "
   {ArcTan[Cos[lat]*Sin[dec] - Cos[dec]*Cos[ha]*Sin[lat], -(Cos[dec]*Sin[ha])],
    ArcTan[Sqrt[Cos[dec]^2*Sin[ha]^2 + (Cos[lat]*Sin[dec] -
         Cos[dec]*Cos[ha]*Sin[lat])^2], Cos[dec]*Cos[ha]*Cos[lat] +
      Sin[dec]*Sin[lat]]}
";

# using MUCH simpler example for syntax testing:

# ArcTan for argument order
# ^2 for **2 stuff
# list for list return stuff

$form = "{Cos[lat] + Cos[dec], Sin[ha], ArcTan[lat,Sin[ha]]^2}";

while ($form=~s/([a-z0-9]+)\[([^\[\]]*?)\]/rubify($1,$2)/ie) {}

debug("FORM: $form");

die "TESTING";

# TODO: consider Mathematica FullForm, it's purer and may help

# TODO: remove unnecessary parens (low pri)

$form = "List[Plus[Cos[dec], Cos[lat]], Sin[ha], Power[ArcTan[lat, ha], 2]]";

# multiline is only for my convenience
$form=~s/\s+/ /g;

# this is for ruby and js, so maybe shouldn't appear here
$form=~s/{/[/g;
$form=~s/}/]/g;
$form=~s/\^/**/g;

# this does all the work and populates the @code array
while ($form=~s/([a-z0-9]+)\[([^\[\]]*?)\]/format1_helper($1,$2)/ie) {}

# write out to ruby and js (TODO: obviously do something else later)

open(A, ">/tmp/blc.rb");

print A << "MARK";

def $fname($vars)
$code
$form
end

print $fname(1,2,3)

MARK
;

close(A);

# NOTE: $code does nothing for right now

open(A, ">/tmp/blc.js");

print A << "MARK";

function $fname($vars) {
$code
return $form;
}

print($fname(1,2,3));

MARK
;





debug("FORM: $form");
debug(@code);

die "TESTING";

# ruby test

# TODO: ruby does ArcTan "backwards", so simplifying formula to return
# four vals

# $form = "
#   {Cos[lat]*Sin[dec] - Cos[dec]*Cos[ha]*Sin[lat], -(Cos[dec]*Sin[ha]),
#    Sqrt[Cos[dec]^2*Sin[ha]^2 + (Cos[lat]*Sin[dec] -
#         Cos[dec]*Cos[ha]*Sin[lat])^2], Cos[dec]*Cos[ha]*Cos[lat] +
#      Sin[dec]*Sin[lat]}
#";


# $form = "ArcTan[x,y]";

# this will be a sticking point later

$form=~s/ArcTan/atan2/g;

# JS starts here







# ruby starts here

while ($form=~s/([a-z0-9]+)\[([^\[\]]*?)\]/rubify($1,$2)/ie) {}

my($code) = join("\n", @code);

print "def $fname($vars)\n$code\n$form\nend\n";

debug("FORM: $form");

debug("CODE", @code);

# ruby ends here

# print test code so I dont have to enter it "by hand" each time

print "print $fname(1,2,3)\n";

sub rubify {
  my($f, $args) = @_;
  debug("GOT: f=$f, args=$args");

  # TODO: ugly ugly ugly; also, ugly
  # flip args if atan2
  if ($f eq "atan2") {
    debug("ARGS1: $args");
    $args=~s/^(.*?),(.*)$/$2,$1/;
    debug("ARGS2: $args");
  }

  return("Math.".lc($f)."($args)");
}

# TODO: this method is SIGNIFIGANTLY uglier, but easier to debug

sub rubify2 {

  # TODO: icky use of global here
  $varcount++;

  # TODO: use an array instead of bad var names?
  # TODO: let "user" choose var name?
  # TODO: declare variables as private
  # TODO: typing nightmare?

  my($f, $args) = @_;
  debug("GOT: f=$f, args=$args");

  warn "TESTING";

  # TODO: ugly ugly ugly; also, ugly
  # flip args if atan2
  if ($f eq "atan2") {
    debug("ARGS1: $args");
    $args=~s/^(.*?),(.*)$/$2,$1/;
    debug("ARGS2: $args");
  }

  # ruby uses Math and lower case function names
  $f = "Math.".lc($f);

  # TODO: @code is global
  push(@code, "var$varcount = $f($args);");
  push(@code, "print \"var $varcount = \", var$varcount, \"\\n\";");

  return "var$varcount";

  next;

  return("Math.".lc($f)."($args)");
}

# TODO: use FORTRAN form?

# TODO: add FORTRAN as supported language (?!)

# TODO: COBOL? BASIC? VBA? (get help from mr x?)

# TODO: go both ways with it

# TODO: mass test cases (and some sort of 'ant' [whatever the hell
# that is] thing?)

=item format1_helper

This helps convert code into a format understood by: Ruby, JS, ??? (others?)

$f: the function name
$args: the comma-separated function arguments

TODO: uses globals extensively (maybe ok as a helper function)

=cut

sub format1_helper {
  my($f, $args) = @_;
  my(@args) = split(/\,\s*/, $args);
  debug("GOT: f=$f, args=", @args);

  # special cases for simple functions
  # TODO: this is wrong for a+b+c when there's more than two args
  if ($f eq "Plus") {
    return "($args[0])+($args[1])";
  }

  # TODO: ugly ugly ugly; also, ugly
  # flip args if arctan AND change to atan2
  # TODO: this will get uglier since I sometimes use one arg form
  if ($f eq "ArcTan") {
    debug("ARGS1: $args");
    $f = "atan2";
    $args=~s/^(.*?),(.*)$/$2,$1/;
    debug("ARGS2: $args");
  }

  return("Math.".lc($f)."($args)");
}

