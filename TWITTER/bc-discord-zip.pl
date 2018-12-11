#!/bin/perl

# does what bc-twitter-zip.pl does but for discord takeout

use Archive::Zip;
require "/usr/local/lib/bclib.pl";
$ENV{TZ} = "UTC";

# read in the given file

my($file) = @ARGV;
my($zip) = Archive::Zip->new();
$zip->read($file);

# find data/js/user_details.js, mtime, and contents (for username)

my($data) = $zip->memberNamed("account/user.json");
my($mtime) = strftime("%Y%m%d.%H%M%S", gmtime($data->lastModTime()));

my($contents) = $data->contents();
my($all) = JSON::from_json($contents);
my($email) = $all->{email};

print "mv $file $email-$mtime.zip\n";
