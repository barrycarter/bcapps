#!/bin/perl

# does what bc-twitter-zip.pl does but for tumblr

use Archive::Zip;
require "/usr/local/lib/bclib.pl";
$ENV{TZ} = "UTC";

# read in the given file

my($file) = @ARGV;
my($zip) = Archive::Zip->new();
$zip->read($file);

# find data/js/user_details.js, mtime, and contents (for username)

# my($data) = $zip->memberNamed("Tumblr/User Data 1/data.json");

# changed 18 Jun 2020

my($data) = $zip->memberNamed("payload-0.json");
my($mtime) = strftime("%Y%m%d.%H%M%S", gmtime($data->lastModTime()));

my($contents) = $data->contents();
my($all) = JSON::from_json($contents);

# changed 18 Jun 2020
# my($email) = $all->{email};

debug(var_dump("XX", $all->[0]));

my($email) = $all->[0]->{data}->{email};

print "ln -s $file $email-$mtime.zip\n";
