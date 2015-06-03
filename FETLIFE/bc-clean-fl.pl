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

  # the unicode subs (from en.wikipedia.org/wiki/Combining_character)
  # TODO: lowercasing unnecessarily below

  # vowels
  s/\xc3[\x80-\x85\xa0-\xa5]/a/g;
  s/\xc3[\xa8-\xab\x88-\x8b]/e/g;
  s/\xc3[\xac-\xaf\x8c-\x8f]/i/g;
  s/\xc3[\xb0\xb2-\xb6\xb8\x92-\x96\x98]/o/g;
  s/\xc3[\xb9-\xbc]/u/g;

  # hybrid or other
  s/\xc3\xa6/ae/g;
  s/\xc3[\xbd\xbf]/y/g;
  s/\xe2\x80[\x90-\x95]/-/g;

  # remove arabic/chinese letters (and some others)
  s/\xef[\xb0-\xbf].//g;
  s/\xe7[\x84-\x8b].//g;

  # nonvowels
  s/\xc3\x87/c/g;
  s/\xc2\xa9/c/g;
  s/\xc3\xa7/c/g;
  s/\xc3\x90/d/g;
  s/\xc2\xa3/L/g;
  s/\xc3\x91/n/g;
  s/\xc3\xb1/n/g;
  s/\xc2\xae/R/g;
  s/\xc2\xa7/SS/g;

  $_=trim($_);

  if (/^[a-z0-9_\?\/\=\,\-\.\:\s]+$/i) {next;}

  debug("STILL A PROB: $_");

}
