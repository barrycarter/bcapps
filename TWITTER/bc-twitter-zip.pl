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

# twitter seriously fucked up/changed their format circa 18 Sep 2018

# twitter is apparently flipping back and forth, so I am uncommenting
# proper lines as needed

# TODO: make below an option (or test multiple), three ways they are
# doing it now

my($data);

for $i ("data/account.js", "data/js/user_details.js", "account.js") {
  $data = $zip->memberNamed($i);
  if ($data) {last;}
};

my($mtime) = strftime("%Y%m%d.%H%M%S", gmtime($data->lastModTime()));
my($contents) = $data->contents();

# find username in contents, die if none

unless ($contents=~s%("screen_name"|"username") : "(.*?)"%%) {die "NO USERNAME";}

my($sn) = $2;

# print the recommended action

print "ln -s $file $sn-$mtime.zip\n";

debug("DATA: $data", $data->lastModTime(), $data->contents());

# debug("MEM", $zip->members());

# debug("ZIP:", var_dump("ZIP", $zip));



