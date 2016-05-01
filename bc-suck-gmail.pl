#!/bin/perl

# In rare cases, you can't IMAP/POP down google mail (eg, third party
# provider); this kludge creates an iMacro script that may help (even
# 'downthemall' won't handle google's bizarre linking format)

require "/usr/local/lib/bclib.pl";
my(@ids);

# input should be save of gmail inbox page; if multiple pages, must
# call script multiple times

while (<>) {

  # we need the GLOBALS line to determine the 'nonce' gmail insists on
  # for viewing messages in original format
  if (/^var GLOBALS/) {$globals = $_; next;}

  while (s/\[\"(.*?)\"//s) {

    # google id numbers are 16 characters long (8 bytes, 18.4
    # quintillion messages possible assuming no check digits)

    unless (length($1) == 16) {next;}

    my($id) = $1;

    # avoid downloading messages twice
    if (-f "$id.txt") {next;}
    push(@ids, $id);
  }
}

my(@globals) = csv($globals);
debug(@globals);
debug("X: $globals[9]");

debug(@ids);

debug($globals);


