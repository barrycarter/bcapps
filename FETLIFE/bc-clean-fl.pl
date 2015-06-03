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

  # the unicode subs
  s/\xc3\xbc/u/g;
  s/\xc2\xa3/L/g;

  # check
  unless (/^[a-z0-9_\?\/\=\,\-\.\:\s]+$/i) {
#  unless (/^[[::print::]]+$/i) {
    debug("BAD: *$_* vs",unidecode($_));
  }
}
