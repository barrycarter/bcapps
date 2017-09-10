#!/bin/perl

# attempts to convert a formula into many different languages

# TODO: rename this rosetta or is that overdone?

require "/usr/local/lib/bclib.pl";

# hardcoded for now

# this is from bc-rst.m

$fname = "HADecLat2azEl";

@vars = ("ha", "dec", "lat");

$vars = join(", ",@vars);

$form = "
   {ArcTan[Cos[lat]*Sin[dec] - Cos[dec]*Cos[ha]*Sin[lat], -(Cos[dec]*Sin[ha])],
    ArcTan[Sqrt[Cos[dec]^2*Sin[ha]^2 + (Cos[lat]*Sin[dec] -
         Cos[dec]*Cos[ha]*Sin[lat])^2], Cos[dec]*Cos[ha]*Cos[lat] +
      Sin[dec]*Sin[lat]]}
";

# multiline is only for my convenience
$form=~s/\s+/ /g;

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

$form=~s/{/[/g;
$form=~s/}/]/g;
$form=~s/\^/**/g;

# this will be a sticking point later

$form=~s/ArcTan/atan2/g;

while ($form=~s/([a-z0-9]+)\[([^\[\]]*?)\]/rubify2($1,$2)/ie) {}

my($code) = join("\n", @code);

print "def $fname($vars)\n$code\n$form\nend\n";

debug("FORM: $form");

debug("CODE", @code);

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

