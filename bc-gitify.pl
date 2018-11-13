#!/bin/perl

# Trivial Perl script that converts a git path to a URL on github

require "/usr/local/lib/bclib.pl";

my($file) = $ARGV[0];

# find canonical directory for file

my($aa);

unless ($file=~m!/!) {$file="./$file";} # add slash if there isn't one already

if ($file=~m!^(/.*/)!) {
  # given file via full path name
  $aa=$1;
} elsif ($file=~m!^(.*/)!) {
  # given file in current directory
  $aa="$ENV{PWD}/$1";
} else {
  die("Can't find dir for $file");
}

$file=~s!(.*/)(.*)$!$aa$2!;
$file=~s!/./!/!g;

unless ($file=~s!^.*BCGIT/!!) {die "NOT IN BCGIT!";}

# microsoft fucks this up and changes blob to tree
# print "https://github.com/barrycarter/bcapps/blob/master/$file\n";

print "https://github.com/barrycarter/bcapps/tree/master/$file\n";



