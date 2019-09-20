#!/bin/perl

# ABANDONED: see convmv

# given file(s) with non-ASCII names on the command line, print out a
# command for renaming them (provided they exist and the target
# doesn't)

require "/usr/local/lib/bclib.pl";

my($nname);

while (<>) {

  chomp();

  unless (-f $_) {debug("NO SUCH FILE: $_"); next;}

  $nname = unidecode($_);

  unless (-f $nname) {
    print qq%mv '$_' '$nname'\n%;
  }
}


