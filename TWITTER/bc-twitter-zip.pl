#!/bin/perl

# attempts to figure out username and twitter archive date from
# archive (for symlink purposes)

use Archive::Zip;
require "/usr/local/lib/bclib.pl";

# read in the given file

my($file) = @ARGV;
my($zip) = Archive::Zip->new();
$zip->read($file);

# find data/js/user_details.js

my($data) = $zip->memberNamed("data/js/user_details.js");

debug("DATA: $data");

# debug("MEM", $zip->members());

# debug("ZIP:", var_dump("ZIP", $zip));



