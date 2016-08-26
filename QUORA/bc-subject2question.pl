#!/bin/perl

# Trivial script that grabs question titles from email subjects like:
# New answer to "[title of question]"

require "/usr/local/lib/bclib.pl";

my(%qs);

while (<>) {

  # silently skip anything that's not a subject
  unless (/^Subject: /) {next;}

  debug("THUNK: $_");
}
