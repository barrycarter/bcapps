#!/bin/perl

# attempts to figure out username and twitter archive date from
# archive (for symlink purposes)

use Archive::Zip;
require "/usr/local/lib/bclib.pl";
$ENV{TZ} = "UTC";

# read in the given file

my($file) = @ARGV;
my($zip) = Archive::Zip->new();
$zip->read($file);

# find data/js/user_details.js, mtime, and contents (for username)

my($data) = $zip->memberNamed("data/js/user_details.js");
my($mtime) = strftime("%Y%m%d.%H%M%S", gmtime($data->lastModTime()));
my($contents) = $data->contents();

# find username in contents, die if none

unless ($contents=~s%"screen_name" : "(.*?)"%%) {die "NO USERNAME";}

my($sn) = $1;

# print the recommended action

print "ln -s $file $sn-$mtime.zip\n";

debug("DATA: $data", $data->lastModTime(), $data->contents());

# debug("MEM", $zip->members());

# debug("ZIP:", var_dump("ZIP", $zip));



