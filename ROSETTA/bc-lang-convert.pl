#!/bin/perl

# attempts to convert a formula into many different languages

# --only: only convert given function

# TODO: rename this rosetta or is that overdone?

# TODO: long-term, use proper temp/subr var conventions for each lang

require "/usr/local/lib/bclib.pl";

# functions that "thread" (in Mathematica) and their binary versions
# TODO: not even close to complete

my(%thread) = ("Plus" => "+", "Times" => "*");

# reads data on languages from "XML" file

my($langs) = read_file("$bclib{githome}/ROSETTA/bc-languages.xml");
my($funcs) = read_file("$bclib{githome}/ROSETTA/bc-functions.xml");

# TODO: temporary for astro testing
warn "ASTRO TESTING";
my($funcs) = read_file("$bclib{githome}/ROSETTA/bc-functions-astro.xml");

# variable to hold languages info
my(%lang);

while ($langs=~s%<language name="(.*?)">(.*?)</language>%%s) {
  my($name, $info) = ($1, $2);

  # language knows its own name
  $lang{$name}{name} = $name;

  while ($info=~s%<(.*?)>(.*?)</\1>%%s) {
    $lang{$name}{$1} = $2;
  }
}

# variable to hold functions info
my(%func);

while ($funcs=~s%<function name="(.*?)">(.*?)</function>%%s) {
  my($name, $info) = ($1, $2);

  # function knows its own name (as fname)
  $func{$name}{fname} = $name;

  while ($info=~s%<(.*?)>(.*?)</\1>%%s) {
    $func{$name}{$1} = $2;
  }

  # mark inactive if --only given
  if ($globopts{only} && ($func{$name}{fname} ne $globopts{only})) {
    $func{$name}{active} = 0;
  }

  # don't run if inactive
  unless ($func{$name}{active}) {
    # delete from hash so it wont show up in loop below
    delete $func{$name};
    next;
  }

  # ignore Mathematica precision
  debug("BODY IS: $func{$name}{body}");
  $func{$name}{body}=~s/\`[\d\.]+//g;

  # multiline is just to make it look nice
  $func{$name}{body}=~s/\s+/ /g;

  # special case for php (and possibly others)
  $func{$name}{dvars}=join(",",map($_="\$$_",split(/\,/,$func{$name}{vars})));
}

debug(dump_var("func", \%func));

# TODO: remove unnecessary parens (low pri)

# TODO: may need parens when converting (or in multiline_parse)

# commands to run to test
my(@runs);

# make copy and then tweak copy

for $i (sort keys %lang) {

  # TODO: setting curlang twice is ugly and unnecesary
  %curlang = %{$lang{$i}};

  # open outfile for this language and read language data
  open(A,">/tmp/blc.$curlang{extension}");

  for $j (sort keys %func) {

    # reset curlang each time (even inside loop) because I change it
    # w/ each loop iteration (which is bad) (TODO: don't do this)
    %curlang = %{$lang{$i}};

    # the current function and language (reset each time to mod below)
    # the current language
    %curfunc = %{$func{$j}};

    # TODO: this could be globalized, but, then again, I may limit it
    # to certain languages; decimate (or perhaps decimalize)
    # everything
    debug("CURFUND: $curfunc{body}");
    # TODO: this is probably broken now, fix
    $curfunc{body}=~s/[^\.\d](\d+)([^\.])/$1.0$2/g;

    debug("FAMMA: $curfunc{body}");

    # ignore inactive functions
    unless ($curfunc{active}) {next;}

    debug("DOING: $i, $j");

    # get testargs (TODO: get more than just last set)
    debug("EPSI: $curfunc{argtest}");

    debug("<FUNC $j>", %{$func{$j}}, "</FUNC>");
    debug("CURFUNC PRE", %curfunc);

    while ($curfunc{body}=~s/([a-z0-9]+)\[([^\[\]]*?)\]/multiline_parse($1,$2,$i)/ie) {}
    while ($curfunc{body}=~s/var(\d+)/$hash{$1}/g) {}

    # this is ugly, since we're defining into a function hash
    # TODO: the trim here is seriously ugly, but python needs it
    $curfunc{body} = trim($curfunc{body});

    debug("BETA: $curfunc{body}");

    # regex below prevents changing things like "<-"
    debug("DELTA: $curlang{fdef}");
    while ($curlang{fdef}=~s/<([a-z]+)>/$curfunc{$1}/g) {}

    # and the code to print it as a test (TODO: improve slightly)
    $curlang{pdef}=~s/<fname>/$curfunc{fname}/g;
    $curlang{pdef}=~s/<args>/$curfunc{argtest}/g;
    $curlang{pdef}=~s/<cval>/$curfunc{answer}}/g;

    debug("CURFUNC GAMMA", %curfunc);
    debug("CURLANG GAMMA", %curlang);

    # attempt to write right here
    print A join("\n", ($curlang{prefix}, $curlang{fdef},
			$curlang{pdef}, $curlang{postfix})),"\n";
    $curlang{run}=~s%<file>%/tmp/blc.$curlang{extension}%g;
  }
    push(@run, $curlang{run});
    close(A);
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

#  debug("GOT: f=$f, args=$args, lang=$lang", @args);

  # TODO: consider making this "Math.", "math.", or "" so used by all
  # the Math object is different for different languages
  my($math) = $lang{$i}{math};

  # if it's defined, add a dot to it
  if ($math) {$math = "$math.";}

  # special cases

  # TODO: not sure I need this special case anymore
  # PHP uses $vars, not vars
  if ($lang eq "php" || $lang eq "perl") {

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

  # TODO: generalize these special cases

  # TODO: actually use <math> field
  # power
  if ($f eq "Power") {

    # TODO: this depends on language
    # TODO: make this part of language definition in bc-langauges.xml
    if ($lang eq "ruby" || $lang eq "python" || $lang eq "perl") {
      $hash{$varcount} = "($args[0])**($args[1])";
    } elsif ($lang eq "javascript" || $lang eq "php") {
      # TODO: should not need parens here, $args should be of form varx
      $hash{$varcount} = "${math}pow($args[0],$args[1])";
    } else {
      $hash{$varcount} = "($args[0])^($args[1])";
    }

    # always return this
    return "var$varcount";
  }

  # in Python/Ruby, abs() is builtin, math.fabs() is math object
  if ($f eq "Abs") {
    if ($lang eq "python") {
      $hash{$varcount} = "${math}fabs($args[0])";
    } elsif ($lang eq "ruby") {
      # this may not work
      $hash{$varcount} = "($args[0].abs())";
    } else {
      $hash{$varcount} = "${math}abs($args[0])";
    }
    return "var$varcount";
  }

  # secant function
  if ($f eq "Sec") {
    $hash{$varcount} = "(1/${math}cos($args[0]))";
    return "var$varcount";
  }

  # Perl doesn't have a Tan function, so I define it here for all langs
  if ($f eq "Tan") {
    $hash{$varcount} = "(${math}sin($args[0])/${math}cos($args[0]))";
    return "var$varcount";
  }


  # the hideousness that is ArcTan
  if ($f eq "ArcTan") {

    $hash{$varcount} = "${math}atan2(($args[1]), $args[0])";
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

  $f = $math.lc($f);

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

