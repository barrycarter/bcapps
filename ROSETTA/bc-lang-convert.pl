#!/bin/perl

# attempts to convert a formula into many different languages

# TODO: rename this rosetta or is that overdone?

# TODO: long-term, use proper temp/subr var conventions for each lang

require "/usr/local/lib/bclib.pl";

# functions that "thread" (in Mathematica) and their binary versions
# TODO: not even close to complete

my(%thread) = ("Plus" => "+", "Times" => "*");

# reads data on languages from "XML" file

my($langs) = read_file("$bclib{githome}/ROSETTA/bc-languages.xml");

# variable to hold language info
my(%lang);

while ($langs=~s%<language name="(.*?)">(.*?)</language>%%s) {
  my($name, $info) = ($1, $2);
  while ($info=~s%<(.*?)>(.*?)</\1>%%s) {
    $lang{$name}{$1} = $2;
  }
}

debug(dump_var("lang", \%lang));

# hardcoded for now

# this is from bc-rst.m

%function = ("fname" => "HADecLat2azEl", "vars" => "ha,dec,lat",
	    "desc" => "This is a test function that does nothing useful...");

# special case for php (and possibly others)

# TODO: this may not belong here, can compute in real time?
$function{dvars} = join(",",map($_="\$$_",split(/\,/,$function{vars})));

# these are the test args (not part of "function")
# TODO: "1.,2.,3." does NOT work w/ ruby, need to floatify/double?
$args = "1.5,2.3,3.4";

# TODO: remove unnecessary parens (low pri)

$function{body} = "
   List[ArcTan[Plus[Times[Cos[lat], Sin[dec]],
      Times[-1, Cos[dec], Cos[ha], Sin[lat]]], Times[-1, Cos[dec], Sin[ha]]],
    ArcTan[Power[Plus[Times[Power[Cos[dec], 2], Power[Sin[ha], 2]],
       Power[Plus[Times[Cos[lat], Sin[dec]],
         Times[-1, Cos[dec], Cos[ha], Sin[lat]]], 2]], Rational[1, 2]],
     Plus[Times[Cos[dec], Cos[ha], Cos[lat]], Times[Sin[dec], Sin[lat]]]]]
";

# multiline is only for my convenience
$form=~s/\s+/ /g;

# TODO: may need parens when converting (or in multiline_parse)

# commands to run to test
my(@runs);

# make copy and then tweak copy

for $i (sort keys %lang) {

  # TODO: this won't work w/ multiple functions because I tweak %lang
  # (which is a bad idea anyway)
  debug("DOING: $i");

  $code = $function{body};
  while ($code=~s/([a-z0-9]+)\[([^\[\]]*?)\]/multiline_parse($1,$2,$i)/ie) {}
  while ($code=~s/var(\d+)/$hash{$1}/g) {}
 
  # this is ugly, since we're defining into a function hash
  # TODO: the trim here is seriously ugly, but python needs it
  $function{code} = trim($code);

  debug("CODE: $function{code}");

  debug("PRE: $i -> $lang{$i}{fdef}");

  # regex below prevents changing things like "<-"
  while ($lang{$i}{fdef}=~s/<([a-z]+)>/$function{$1}/g) {}

  debug("POST: $i -> $lang{$i}{fdef}");

  # and the code to print it as a test (TODO: improve slightly)
  $lang{$i}{pdef}=~s/<fname>/$function{fname}/g;
  $lang{$i}{pdef}=~s/<args>/$args/g;

  # attempt to write right here
  open(A,">/tmp/blc.$lang{$i}{extension}");
  print A join("\n", ($lang{$i}{prefix}, $lang{$i}{fdef}, 
		      $lang{$i}{pdef}, $lang{$i}{postfix})),"\n";
  close(A);

  $lang{$i}{run}=~s%<file>%/tmp/blc.$lang{$i}{extension}%g;
  push(@run, $lang{$i}{run});
  debug("RUN: $lang{$i}{run}");
}

debug("RUN ME:",@run);

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

  # TODO: consider making this "Math.", "math.", or "" so used by all
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

# TODO: generic autogenerated function disclaimer (link to meta-disclaimer)

# TODO: per language comments explaining what function does

# TODO: consider using named args and/or sending/returning hashes only

# TODO: do test single argument version

=item comment

R --no-save < /tmp/blc.r
js /tmp/blc.js
lua /tmp/blc.lua
php /tmp/blc.php
python /tmp/blc.py
ruby /tmp/blc.rb

=cut

