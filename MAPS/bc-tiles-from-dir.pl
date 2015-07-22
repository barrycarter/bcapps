#!/bin/perl

# treats given directory as "slippy tile directory" and displays it
# for google maps

require "/usr/local/lib/bclib.pl";

# TODO: don't hardcode
my($dir) = "/sites/MAP/IMAGES/TEST";

%query = str2hash($ENV{QUERY_STRING});
my($x,$y,$z) = ($query{x}, $query{y},$query{zoom});

# TODO: pretty much just display z,x,y
my($file) = "$dir/$z,$x,$y.jpg";
unless (-f $file) {$file = "$dir/blank.jpg";}
print "Content-type: image/jpeg\n\n";
print read_file($file);



