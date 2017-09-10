#!/bin/perl

# attempts to convert a formula into many different languages

# TODO: rename this rosetta or is that overdone?

# TODO: long-term, use proper temp/subr var conventions for each lang

require "/usr/local/lib/bclib.pl";

# functions that "thread" (in Mathematica) and their binary versions
# TODO: not even close to complete

my(%thread) = ("Plus" => "+", "Times" => "*");

# code gets stored here
my(@code);

# hardcoded for now

# this is from bc-rst.m

$fname = "f1";

@vars = ("ha", "dec", "lat");

$vars = join(", ",@vars);

# special case for php

# TODO: handle these special cases much better

@phpvars = @vars;
for $i (@phpvars) {$i= "\$$i";}
$phpvars = join(", ", @phpvars);

$desc = "This is a test function that does nothing useful... unless you consider testing useful... then it does something useful... but not useful to you... unles you're testing with me";

# TODO: remove unnecessary parens (low pri)

# using MUCH simpler example for syntax testing:

# ArcTan for argument order
# ^2 for **2 stuff
# Sin[ha] inside ArcTan for composition testing
# list for list return stuff

# inputform (for reference only):
# {Cos[dec] + Cos[lat], Sin[ha], ArcTan[lat, Sin[ha]]^2}

$form="
List[Plus[Cos[dec], Cos[lat]], Sin[ha], Power[ArcTan[lat, Sin[ha]], 2]]
";

# multiline is only for my convenience
$form=~s/\s+/ /g;

# TODO: may need parens here (or in multiline_parse)

# TODO: subroutinize

# make copy and then tweak copy

my($ruby) = $form;
while ($ruby=~s/([a-z0-9]+)\[([^\[\]]*?)\]/multiline_parse($1,$2,"ruby")/ie) {}
while ($ruby=~s/var(\d+)/$hash{$1}/g) {}

my($js) = $form;
while ($js=~s/([a-z0-9]+)\[([^\[\]]*?)\]/multiline_parse($1,$2,"js")/ie) {}
while ($js=~s/var(\d+)/$hash{$1}/g) {}


debug("STARTING PHP");
my($php) = $form;

while ($php=~s/([a-z0-9]+)\[([^\[\]]*?)\]/multiline_parse($1,$2,"php")/ie) {
  debug("PHP: $php");
}

for $i (sort {$a <=> $b} keys %hash) {debug("HASH($i) => $hash{$i}");}

while ($php=~s/var(\d+)/$hash{$1}/g) {}
debug("ENDING PHP");


# TODO: subroutinize and handle output better

# write out to ruby
open(A, ">/tmp/blc.rb");
print A << "MARK";
def $fname($vars) $ruby end
print $fname(1,2,3)
MARK
;
close(A);


# write to JS
open(A, ">/tmp/blc.js");
print A << "MARK";
function $fname($vars) {return $js;}
print($fname(1,2,3));
MARK
;
close(A);

# write to PHP
open(A, ">/tmp/blc.php");
print A << "MARK";
<?
function $fname($phpvars) {return $php;}
print_r($fname(1,2,3));
?>
MARK
;
close(A);

=item multline_parse($f, $args, $lang)

$f: function name
$args: arguments to that function
$lang: programming language

Create a (global) list of variable assignments that ultimately yield
the result of a calculation (may eventually become a helper for inline
functions)

# TODO: this method is SIGNIFIGANTLY uglier, but easier to debug
# TODO: use an array instead of bad var names?
# TODO: use internal format \0 (num) \0 or something?
# TODO: let "user" choose var name?
# TODO: declare variables as private
# TODO: typing nightmare?

# TODO: consider releasing in var1 = ... form as well

=cut

sub multiline_parse {

  my($f, $args, $lang) = @_;
  my(@args) = split(/\,\s*/, $args);

  # TODO: icky use of global here
  $varcount++;

  debug("GOT: f=$f, args=$args, lang=$lang", @args);

  # special cases

  # PHP uses $vars, not vars
  if ($lang eq "php") {
    for $i (@args) {$i = "\$$i";}
    $args = join(", ", @args);
  }

  # list
  if ($f eq "List") {
 
    # TODO: this might be cheating, do I need parens?

    if ($lang eq "php") {
      $hash{$varcount} = "array($args)";
    } else {
      $hash{$varcount} = "[$args]";
    }

    return "var$varcount";
  }

  # power
  if ($f eq "Power") {

    # TODO: this depends on language
    if ($lang eq "ruby") {
      $hash{$varcount} = "($args[0])**($args[1])";
    } elsif ($lang eq "js") {
      # TODO: should not need parens here, $args should be of form varx
      $hash{$varcount} = "Math.pow($args[0],$args[1])";
    } else {
      $hash{$varcount} = "($args[0])^($args[1])";
    }
    
    # always return this
    return "var$varcount";
  }

  # the hideousness that is ArcTan
  if ($f eq "ArcTan") {

    # TODO: this depends on language???
#    $hash{$varcount} = "Math.atan2(($args[1]),($args[0]))";

    if ($lang eq "ruby") {
      $hash{$varcount} = "Math.atan2(($args[1]),($args[0]))";
    } elsif ($lang eq "js") {
      $hash{$varcount} = "Math.atan2(($args[1]),($args[0]))";
    } else {
      $hash{$varcount} = "atan2(($args[0]), $args[1])";
    }

    return "var$varcount";
  }

  # threaded functions

  if ($thread{$f}) {

    # add parens
    for $i (@args) {$i="($i)";}

    # and add
    $hash{$varcount} = join($thread{$f}, @args);

    return "var$varcount";
  }

#  warn "TESTING"; return "var$varcount";


  # TODO: ugly ugly ugly; also, ugly
  # flip args if atan2
  if ($f eq "atan2") {
    debug("ARGS1: $args");
    $args=~s/^(.*?),(.*)$/$2,$1/;
    debug("ARGS2: $args");
  }

  # ruby uses Math and lower case function names, as does js, but not php

  if ($lang eq "php") {
    $f = lc($f);
  } else {
    $f = "Math.".lc($f);
  }

  # TODO: @code is global
  push(@code, "var$varcount = $f($args);");

  # this GLOBAL hash assignment allows us to unfold variables later
  $hash{$varcount} = "$f($args)";

  push(@code, "print \"var $varcount = \", var$varcount, \"\\n\";");

  return "var$varcount";
}

# TODO: use FORTRAN form?

# TODO: add FORTRAN as supported language (?!)

# TODO: COBOL? BASIC? VBA? (get help from mr x?)

# TODO: go both ways with it

# TODO: mass test cases (and some sort of 'ant' [whatever the hell
# that is] thing?)

# TODO: uses globals extensively (maybe ok as a helper function)

# TODO: annoy codreview.SE?

