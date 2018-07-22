#!/bin/perl

# Given a file containing a single email, extract the attachment(s0

require "/usr/local/lib/bclib.pl";

my($data, $name) = cmdfile();

# debug("DATA: $data");

# split into head and body

my($head, $body) = split(/\n\n/, $data);

# fix continuation lines in header

$head=~s/\n\s+/ /sg;

# find MIME boundaries

my(%boundaries);

  while ($head=~s/^Content-[tT]ype: (.*?)(;.*)?$//m) {

  # type is MIMEtype, extra is boundary + charset (for example)
  my($type, $extra) = ($1,$2);

  # $extra should contain a boundary
  unless ($extra=~/boundary=\"(.*?)\"/) {
    warn("MIME w/ no boundary: $name");
    next;
  }

  $boundary{$1} = 1;
}

# now that we know MIME boundaries, extract them from file (see
# ../bc-extract-attachments for the wrong way of doing this because of
# Perl's broken regex limits)

for $i (split(/\n/,$body)) {
  debug("I: $i");
}
