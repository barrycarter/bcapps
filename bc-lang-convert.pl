#!/bin/perl

# attempts to convert a formula into many different languages

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

# ruby test

# TODO: ruby does ArcTan "backwards", so simplifying formula to return
# four vals

$form = "
   {Cos[lat]*Sin[dec] - Cos[dec]*Cos[ha]*Sin[lat], -(Cos[dec]*Sin[ha]),
    Sqrt[Cos[dec]^2*Sin[ha]^2 + (Cos[lat]*Sin[dec] -
         Cos[dec]*Cos[ha]*Sin[lat])^2], Cos[dec]*Cos[ha]*Cos[lat] +
      Sin[dec]*Sin[lat]}
";


$form=~s/{/[/g;
$form=~s/}/]/g;
$form=~s/\^/**/g;

# this will be a sticking point later

$form=~s/ArcTan/atan2/g;

while ($form=~s/([a-z0-9]+)\[([^\[\]]*?)\]/rubify($1,$2)/ie) {}

print "def $fname($vars) $form end";

debug("FORM: $form");

sub rubify {
  my($f, $args) = @_;
  debug("GOT: f=$f, args=$args");
  return("Math.".lc($f)."($args)");
}





