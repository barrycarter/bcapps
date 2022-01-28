#!/bin/perl

# Do what:

# egrep '^(From|Subject|To|Reply-to|Return-Path|Status|X-Status):' <filenames>

# would do, but assume <filenames> are mailboxes, and only grep in headers

# to match egrep, prepend matches with filename

require "/usr/local/lib/bclib.pl";

my($inheader);

for $i (@ARGV) {

  open(A,$i);

  while (<A>) {

#    debug("GOT: $_, INH: $inheader");

    if (/^From \S+ (mon|tue|wed|thu|fri|sat|sun)/i) {
      debug("ENTERING INHEADER: $_");
      $inheader = 1;
    }

    if (/^$/) {$inheader = 0; next;}

    if (/^(From|Subject|To|Reply-to|Return-Path|Status|X-Status):/ && $inheader) {

      debug("INH: $_");
      print "$i:$_";
    }
  }

  close(A);
}



