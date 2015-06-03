#!/bin/perl

# This trivial script cleans up a fetlife user dump by "fixing"
# unicode errors, etc

# <h>There's a joke in here somewhere about "cleaning up FetLife" ha ha</h>

require "/usr/local/lib/bclib.pl";

# the id line ends up at the bottom, which is bad, so we reprint it
# here, ignore it later

# TODO: this currently hardcoded
print "id,screenname,age,gender,role,city,state,country,thumbnail,popnum,popnumtotal,source,mtime\n";

while (<>) {
  chomp;

  # ignore the 0 line that occurs because FetLife sometimes misspells
  # "users" (I have no idea how this can happen given their site is
  # probably automated, but oh well)
  if (/^0+\,|^id/) {next;}

  # TODO: changing URLs and stuff will break them, this should really
  # limit changes to just city/state/country or something (ie, purely
  # for bc-cityfind.pl)

  # no apostrophes
  s/\&\#x27\;//g;

  # this is going to break stuff, but OK w/ that
  s/\s*\(.*?\)\s*/ /g;

  # similar for plus signs
  s/\s*\+\s*/ /g;

  # kill all unicode charcters (sigh)
  s/[^a-z0-9_\?\/\=\,\-\.\:\s]//gi;

  $_=trim($_);

  print "$_\n";

#  if (/^[a-z0-9_\?\/\=\,\-\.\:\s]+$/i) {next;}

}
