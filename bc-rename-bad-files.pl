#!/bin/perl

# given file(s) with spaces or parens non-ASCII on the stdin, print
# out a command for renaming them (provided they exist and the target
# doesn't)

require "/usr/local/lib/bclib.pl";

my($nname);

while (<>) {

  chomp();

  unless (-f $_) {debug("NO SUCH FILE: $_"); next;}

  $nname = $_;

  # if no change do nothing

  unless ($nname=~s/[\s\(\)]/_/g) {next;}

  unless (-f $nname) {
    print qq%mv -i "$_" "$nname"\n%;
  }
}


