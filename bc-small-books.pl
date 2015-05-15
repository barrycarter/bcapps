#!/bin/perl

# Given a list of books (files) in sorted size order, print out things
# that are books and do not appear to be repeats of other books

# NOTE: this is currently extremely ill-defined

require "/usr/local/lib/bclib.pl";

# extensions we ignore

my(%ignore) = list2hash(
			"tan", "nomedia", "xsc", "cat", "js", "ini",
			"rb", "gif", "", "diz", "dir", "java", "url",
			"wi", "class", "user", "webm", "png", "m", "zip",
			"sfv", "xib", "hpp", "h", "cs", "php", "jpg", "py"
		       );

while (<>) {
  chomp;
  my(@arr) = split(/\s+/,$_,9);
  my($fname,$type) = @arr[-1,4];
  unless ($type eq "f") {next;}

  # get extension
  my($ext);
  if ($fname=~/^.*\.(.*)$/) {$ext=$1;} else {$ext="";}

  if ($ignore{lc($ext)}) {next;}

  print "$fname\n";

}
