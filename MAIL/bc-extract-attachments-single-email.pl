#!/bin/perl

# Given a file containing a single email, extract the attachment(s0

# TODO: use header information to timestamp created files (but use
# mimeexplode as subprocess)

# TODO: if called w/ multiple args, self-invoke xargs -n 1 (danger?) 
# (with null sep just in case spaces in filenames?)

die "Abandoned; see mimeexplode";

require "/usr/local/lib/bclib.pl";

my($data, $name) = cmdfile();

# debug("DATA: $data");

# split into head and body

my($head, $body) = split(/\n\n/, $data, 2);

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

# find fields other than boundaries in header (we probably won't use
# most of these)

my(%head);

# special case for "from xxx fulldate"

if ($head=~s/^From (.*?) (.*)$//m) {
  # TODO: I am assuming these fields don't appear in other/real headers
  $head{envelopesender} = $1;
  $head{fulldate} = $2;
}

while ($head=~s/^(.*?): (.*)$//m) {$head{$1} = $2;}

# this should now be empty
debug("HEAD: $head");

# now that we know MIME boundaries, extract them from file (see
# ../bc-extract-attachments for the wrong way of doing this because of
# Perl's broken regex limits)

# we start off outside any MIME attachment
my($inmime) = 0;

# the lines in the current attachment
# TODO: can MIME have nested attachments?
my(@lines);

for $i (split(/\n/,$body)) {

  # if we see a MIME boundary, we are starting a new attachment

  

  debug("I: $i");
}
