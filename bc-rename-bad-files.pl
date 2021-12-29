#!/bin/perl

# given file(s) with spaces or parens non-ASCII on the stdin, print
# out a command for renaming them (provided they exist and the target
# doesn't)

# changing default behavior to just change "unprintable" characters

# TODO: add more modes for fixing other chars

require "/usr/local/lib/bclib.pl";

my($nname);

while (<>) {

  chomp();

  if (m%\"%) {
    debug("Can't handle quotes: $_");
    next;
  }

  unless (-f $_) {debug("NO SUCH FILE: $_"); next;}

  $nname = $_;

  my($changed) = 0;

  # being careful here: anything not between ASC 32-126 is bad

  if ($nname=~s/[^ -~]/_/g) {$changed=1;}

#  if ($nname=~s/[\s\(\)]/_/g) {$changed=1;}

  if ($changed && !(-f $nname)) {
    print qq%mv -i "$_" "$nname"\n%;
  }
}



