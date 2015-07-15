#!/bin/perl

# bzcat's its output after adding a content-type header so that:
# ".bz2" => "/usr/local/bin/bc-page-bunzip2.pl"
# auto-decompresses bzip2 files

print "Content-type: text/html\n\n";
system("bzcat $ARGV[0]");
