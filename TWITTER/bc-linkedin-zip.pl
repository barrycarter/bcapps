#!/bin/perl

# does what bc-twitter-zip.pl does but for google takeout

# TODO: this only works if archive chunk has Takeout/index.html in it;
# for multi-chunk takeouts, not all chunks will have this

use Archive::Zip;
require "/usr/local/lib/bclib.pl";
$ENV{TZ} = "UTC";

# read in the given file

my($file) = @ARGV;

my($zip) = Archive::Zip->new();
$zip->read($file);

# find the primary email address by splitting the Email Addresses.csv file
# and mtime of file

my($data) = $zip->memberNamed("Email Addresses.csv");
my($mtime) = strftime("%Y%m%d.%H%M%S", gmtime($data->lastModTime()));
my(@lines);
for $i (split(/\n/, $data->contents())) {push(@lines, [csv($i)]);}
my($listref) = arraywheaders2hashlist(\@lines);
my(@hashes) = @$listref;

my($primary);

for $i (@hashes) {
  if ($i->{Primary} eq "Yes") {$primary="$i->{'Email Address'}"; last;}
}

unless ($primary && $mtime) {die "Something went wrong";}

# recommended symlink
print "ln -s '$file' $primary-$mtime.zip\n";
