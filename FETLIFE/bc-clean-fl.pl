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

  if (/^[a-z0-9_\?\/\=\,\-\.\:\s]+$/i) {next;}

  debug("PROB: $_");

  # TODO: changing URLs and stuff will break them, this should really
  # limit changes to just city/state/country or something (ie, purely
  # for bc-cityfind.pl)

  # no apostrophes
  s/\&\#x27\;//g;

  # the unicode subs (from en.wikipedia.org/wiki/Combining_character)
  # TODO: lowercasing unnecessarily below
  s/\xc3[\x80-\x85\xa0-\xa5]/a/g;
  s/\xc3[\xa8-\xab\x88-\x8b]/e/g;
  s/\xc3[\xac-\xaf]/i/g;
  s/\xc3[\xb0\xb2-\xb6\xb8]/o/g;
  s/\xc3[\xb9-\xbc]/u/g;
  s/\xc2\xa3/L/g;
  s/\xc2\xae/R/g;
  s/\xc2\xa7/SS/g;

  debug("AFTER: $_");

}
