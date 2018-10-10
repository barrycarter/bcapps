#!/bin/perl

# Creates full list of tests from nagyerass.cfg expanding $$var$$ as needed

require "/usr/local/lib/bclib.pl";

my($all, $fname) = cmdfile();

# TODO: this could catch test sections outside of tests, in theory

while ($all=~s%<test>(.*?)</test>%%s) {

  my($test) = $1;
  my($glob) = 0;

  unless ($test=~m/^\$\$.*?\$\$\s*\=\s*.*$/m) {
    print "<test>$test</test>\n\n";
    next;
  }

  # TODO: this currently only works for one variable (for multiple,
  # could do some sort of mod and multiply thing or Math::Cartesian::Product)

  my(%vars);

  while ($test=~s/^\$\$(.*?)\$\$\s*\=\s*(.*)$//m) {
    my($var, $vals) = ($1, $2);

    # vals is always a list, possibly from a file
    # TODO: handle file case

    my(@vals);

    if ($vals=~/\@(.*)$/m) {
      @vals = `egrep -v '^\$|^#' $1`;
    } else {
      @vals = split(/\,\s*/, $vals);
    }

    # create a copy of the test for each item in vals
    for $i (@vals) {
      my($testcopy) = $test;

      # replace the name with an added dot
      # TODO: this might be excessive
      $testcopy=~s/^(name\s*\=.*)$/$1.$i/m;

      # replace the var
      $testcopy=~s/\$\$$var\$\$/$i/g;

      # this is just cleanup
      $testcopy=~s/\n+/\n/sg;

      print "<test>$testcopy</test>\n\n";
    }
  }
}





