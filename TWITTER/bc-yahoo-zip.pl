#!/bin/perl

# does what bc-twitter-zip.pl does but for yahoo

# TODO: this really belongs in a YAHOO dir, not a TWITTER dir

use Archive::Zip;
require "/usr/local/lib/bclib.pl";
$ENV{TZ} = "UTC";

# read in the given file

my($file) = @ARGV;
my($zip) = Archive::Zip->new();
$zip->read($file);

# find "Your Account/User Data 1/data.json" and locate username

my($data) = $zip->memberNamed("Your Account/User Data 1/data.json")->contents();

unless ($data=~s/"identifier": "(.*?)"//m) {die("BAD FILE!");}

my($sn) = $1;

# find the data timestamp in the manifest.json file

$data = $zip->memberNamed("manifest.json")->contents();

unless ($data=~s%Activity Data/User Data 1/[0-9]{8}T[0-9]{6}\-([0-9]{8}T[0-9]{6})\-data.json%%m) {
  die("could not find data file in manifest");
}

my($mtime) = strftime("%Y%m%d.%H%M%S", gmtime(str2time($1)));

if (-f "$sn-$mtime.zip") {
  print "$sn-$mtime.zip already exists\n";
  exit(-1);
}

print "ln -s '$file' $sn-$mtime.zip\n";

