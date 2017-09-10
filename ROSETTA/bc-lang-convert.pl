#!/bin/perl

# attempts to convert a formula into many different languages

# TODO: rename this rosetta or is that overdone?

# TODO: long-term, use proper temp/subr var conventions for each lang

require "/usr/local/lib/bclib.pl";

# functions that "thread" (in Mathematica) and their binary versions
# TODO: not even close to complete

my(%thread) = ("Plus" => "+", "Times" => "*");

# file extensions

%extensions = ("ruby" => "rb", "js" => "js", "lua" => "lua", "php" => "php",
 "python" => "py", "R" => "r");

# prefix and postfix to function code

$prefix{python} = "import math;";
$prefix{php} = "<?";
$postfix{php} = "?>";

# what a function looks like in various languages where:

# $FNAME$ is the function name
# $VARS$ is the comma-separated arguments (TODO: always csv?)
# $DVARS$ is the dollar-sign-prefixed comma-separate arguments
# $CODE$ is the generated code

my(%fdef);

$fdef{ruby} = "def $FNAME$($VARS$) $CODE$ end";
$fdef{js} = "function $FNAME$($VARS$) {return $CODE$;}";
$fdef{lua} = "function $FNAME$($VARS$) return $CODE$ end";
$fdef{R} = "$FNAME$ <- function($VARS$) {return($CODE$)}";

# python requires "import math";
$fdef{python} = "def $FNAME$($VARS$):
  return $CODE$
";

# PHP requires special vars and must have "<?" and "?>" tags, nonstandard
$fdef{php} = "function $FNAME$($DVARS$) {return $CODE$;}";

# how to print/test variables where:
# $FNAME$ is function name
# $ARGS$ is comma-separated args (but will they always be?)

my(%pdef);

$pdef{ruby} = "print $FNAME$($ARGS$)";
$pdef{js} = "print_r($FNAME$($ARGS$));";
$pdef{lua} = "print($FNAME$($ARGS$))";
$pdef{python} = "print($FNAME$($ARGS$))";
$pdef{R} = "print($FNAME$($ARGS$))";

# code gets stored here
my(@code);

# hardcoded for now

# this is from bc-rst.m

$fname = "HADecLat2azEl";

@vars = ("ha", "dec", "lat");

$vars = join(", ",@vars);

# special case for php (and possibly others)

@phpvars = @vars;
for $i (@phpvars) {$i= "\$$i";}
$phpvars = join(", ", @phpvars);
$dvars = $phpvars;

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

# actual function from bc-rst.m

$form = "
   List[ArcTan[Plus[Times[Cos[lat], Sin[dec]],
      Times[-1, Cos[dec], Cos[ha], Sin[lat]]], Times[-1, Cos[dec], Sin[ha]]],
    ArcTan[Power[Plus[Times[Power[Cos[dec], 2], Power[Sin[ha], 2]],
       Power[Plus[Times[Cos[lat], Sin[dec]],
         Times[-1, Cos[dec], Cos[ha], Sin[lat]]], 2]], Rational[1, 2]],
     Plus[Times[Cos[dec], Cos[ha], Cos[lat]], Times[Sin[dec], Sin[lat]]]]]
";



# multiline is only for my convenience
$form=~s/\s+/ /g;

# TODO: may need parens here (or in multiline_parse)

# TODO: subroutinize

# hash of language-specific code
my(%lcode);

# make copy and then tweak copy

for $i ("php", "ruby", "js", "lua", "python", "R") {
  $code = $form;
  while ($code=~s/([a-z0-9]+)\[([^\[\]]*?)\]/multiline_parse($1,$2,$i)/ie) {}
  while ($code=~s/var(\d+)/$hash{$1}/g) {}
  $lcode{$i} = $code;
}

# TODO: subroutinize and handle output better

# write to Ruby
open(A, ">/tmp/blc.rb");
print A << "MARK";
def $fname($vars) $lcode{ruby} end
print $fname(1,2,3)
MARK
;
close(A);


# write to JS
open(A, ">/tmp/blc.js");
print A << "MARK";
function $fname($vars) {return $lcode{js};}
print($fname(1,2,3));
MARK
;
close(A);

# write to PHP
open(A, ">/tmp/blc.php");
print A << "MARK";
<?
function $fname($phpvars) {return $lcode{php};}
print_r($fname(1,2,3));
?>
MARK
;
close(A);

# write to LUA
open(A, ">/tmp/blc.lua");
print A << "MARK";
function $fname($vars) return $lcode{lua} end
print($fname(1,2,3))
MARK
;
close(A);

# write to Python
open(A, ">/tmp/blc.py");
print A << "MARK";
import math;
def $fname($vars):
 return $lcode{python}

print($fname(1,2,3))
MARK
;
close(A);

# write to R
open(A, ">/tmp/blc.r");
print A << "MARK";
$fname <- function($vars) {return($lcode{R})}
print($fname(1,2,3))
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

  # the Math object is different for different languages
  my($math);

  if ($lang eq "lua" || $lang eq "python") {
    $math = "math";
  } else {
    $math = "Math";
  }

  # special cases

  # PHP uses $vars, not vars
  if ($lang eq "php") {

    # vars that we create are immune as are non-alpha
    for $i (@args) {
      unless ($i=~/^var\d+$/ || $i=~/^[^a-z]/i) {
	$i = "\$$i";
      }
    }
    $args = join(", ", @args);
  }

  # rational number
  if ($f eq "Rational") {
    $hash{$varcount} = "($args[0])/($args[1])";
    return "var$varcount";
  }

  # list
  if ($f eq "List") {

    # TODO: this might be cheating, do I need parens?

    if ($lang eq "php") {
      $hash{$varcount} = "array($args)";
    } elsif ($lang eq "lua") {
      # unchanged for lua?
      $hash{$varcount} = $args;
    } elsif ($lang eq "R") {
      $hash{$varcount} = "list($args)";
    } else {
      $hash{$varcount} = "[$args]";
    }

    return "var$varcount";
  }

  # power
  if ($f eq "Power") {

    # TODO: this depends on language
    if ($lang eq "ruby" || $lang eq "python") {
      $hash{$varcount} = "($args[0])**($args[1])";
    } elsif ($lang eq "js") {
      # TODO: should not need parens here, $args should be of form varx
      $hash{$varcount} = "$math.pow($args[0],$args[1])";
    } elsif ($lang eq "php") {
      $hash{$varcount} = "pow($args[0],$args[1])";
    } else {
      $hash{$varcount} = "($args[0])^($args[1])";
    }
    
    # always return this
    return "var$varcount";
  }

  # the hideousness that is ArcTan
  if ($f eq "ArcTan") {

    if ($lang eq "php" || $lang eq "R") {
      $hash{$varcount} = "atan2(($args[1]), $args[0])";
    } else {
      # argument reversal by default (stupid Mathematica!)
      $hash{$varcount} = "$math.atan2(($args[1]),($args[0]))";
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

  # ruby uses Math and lower case function names, as does js, but not php

  if ($lang eq "php" || $lang eq "R") {
    $f = lc($f);
  } else {
    $f = "$math.".lc($f);
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

# TODO: generic autogenerated function disclaimer

# TODO: per language comments explaining what function does

