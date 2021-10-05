#!/bin/perl

# I have an annotation program (not in BCGIT) that uses the sha1 of
# the body of an email as the filename for the annotation; this maps
# each mail message to its sha1sum

require "/usr/local/lib/bclib.pl";

# my($fname) = @ARGV;

# open(A,$fname)||die("Can't open $fname, $!");

($head, $body) = next_email_fh("");

debug("HEAD", $head, "BODY", $body);

