#!/bin/perl

# does what bc-twitter-zip.pl does but for google takeout

# TODO: this only works if archive chunk has Takeout/index.html in it;
# for multi-chunk takeouts, not all chunks will have this

use Archive::Zip;
require "/usr/local/lib/bclib.pl";
$ENV{TZ} = "UTC";

# read in the given file

my($file) = @ARGV;

unless ($file=~/takeout\-(\d{8}T\d{6}Z)\-\d+\.zip/) {
  die("INVALID FILENAME: $file");
}

my($date) = $1;

my($zip) = Archive::Zip->new();
$zip->read($file);

# find data/js/user_details.js, mtime, and contents (for username)

my($data) = $zip->memberNamed("Takeout/index.html");
my($contents) = $data->contents();
unless ($contents=~s%archive for (.*?)<%%i) {die "NO USERNAME";}

my($sn) = $1;

# print the recommended action

print "ln -s '$file' $sn-$date.zip\n";
