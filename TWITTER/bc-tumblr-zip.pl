#!/bin/perl

# does what bc-twitter-zip.pl does but for tumblr

use Archive::Zip;
require "/usr/local/lib/bclib.pl";
$ENV{TZ} = "UTC";

# read in the given file

my($file) = @ARGV;
my($zip) = Archive::Zip->new();
$zip->read($file);

# check two files for data

my($data) = $zip->memberNamed("Tumblr/User Data 1/data.json");

unless ($data) {$data = $zip->memberNamed("payload-0.json");}

# find data/js/user_details.js, mtime, and contents (for username)

my($mtime) = strftime("%Y%m%d.%H%M%S", gmtime($data->lastModTime()));

my($contents) = $data->contents();
my($all) = JSON::from_json($contents);

my($email);

if (ref($all) eq "HASH") {
  $email = $all->{email};
} else {
  $email = $all->[0]->{data}->{email};
}

print "ln -s $file $email-$mtime.zip\n";
