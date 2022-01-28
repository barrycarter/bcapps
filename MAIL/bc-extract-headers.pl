#!/bin/perl

# Trivial script to extract headers from <>

# have written very similar stuff in: bc-extract-attachments.pl
# bc-split-mail.pl

# TODO: currently, we're only interested in headers with colons which
# means we miss continuation lines and even the "From " header used to
# split messages; consider doing something about this

# we also disclude colons that come in the header value

# UGH... later I decide only to grab specific headers, which really
# reduces the general value of this program

my($inheader);

while (<>) {

  if (/^From \S+ (mon|tue|wed|thu|fri|sat|sun)/i) {
    $inheader = 1;
  }

  if (/^$/) {$inheader = 0; next;}

  if (/^(From|Subject|To|Reply-to|Return-Path|Status|X-Status):/) {
    print $_;
  }

}


