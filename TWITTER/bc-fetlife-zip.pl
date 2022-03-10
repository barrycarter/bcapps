#!/bin/perl

# does what bc-twitter-zip.pl does but for fetlife

use Archive::Zip;
require "/usr/local/lib/bclib.pl";
$ENV{TZ} = "UTC";

# read in the given file

my($file) = @ARGV;

my($zip) = Archive::Zip->new();
$zip->read($file);

# the data we need is in _meta.txt

my($data) = $zip->memberNamed("_meta.txt");

my($contents) = $data->contents();

unless ($contents=~s%Data Export for member (\d+)\, (.*?)\. Created on (\d{4}/\d{2}/\d{2}) (\d{2}:\d{2}:\d{2}) \+0000\.%%) {
  die("BAD DATA");
}

my($user, $date, $time) = ($2, $3, $4);

# remove hyphens and colons

$date=~s%/%%g;

$time=~s/://g;

print "ln -s '$file' $user-$date.$time.zip\n";
