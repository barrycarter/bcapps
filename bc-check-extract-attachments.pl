#!/bin/perl

# Confirms that bc-extract-attach.pl didn't do anything horrible

require "/usr/local/lib/bclib.pl";
use IO::File;

(($file) = shift) || die("Usage: $0 filename");

# if they gave us regular name, use extracted name
unless ($file=~/\.extracted$/) {$file = "$file.extracted";}

if (-f "$file.cmp") {die("$file.cmp exists");}

open(A,$file)||die("Can't open $file, $!");
open(B,">$file.cmp")||die("Can't open $file.cmp, $!");

# phrase to match (had to work this out; it's sort of the mimedecode
# of "[SEE /usr/local/etc/sha/" but not quite)

$phrase = "W1NFRSAvdXNyL2xvY2FsL2V0Y";

while (<A>) {
  # normally, just print to outfile
  unless (/$phrase/) {
    print B $_;
    next;
  }

  debug("LINE MATCH: $_");

  # matching phrase, so decode
  $str = decode_base64($_);
  debug("DECODED: $str");

  # find file (if this is a coincidental match, ignore)
  unless ($str=~m%^\[SEE (/usr/local/etc/sha/.*?)\]$%) {print B $_; next;}
  my($infile) = $1;
  debug("INSERTING: $infile");

  print B read_file($infile),"\n";
}
