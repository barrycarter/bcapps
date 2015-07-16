#!/bin/perl

# treats given directory as "slippy tile directory" and displays it
# for google maps

require "/usr/local/lib/bclib.pl";

# TODO: don't hardcode
my($dir) = "/sites/MAP/IMAGES/TEST";

%query = str2hash($ENV{QUERY_STRING});
my($x,$y,$z) = ($query{x}, $query{y},$query{zoom});

# TODO: THIS IS JUST TESTING!!!
$x-=19;
$y-=44;

# TODO: pretty much just display z,x,y
my($file);

if (-f "$dir/$z,$x,$y.png") {
  $file = "$dir/$z,$x,$y.png";
} else {
  $file = "$dir/blank.png";
}

print "Content-type: image/png\n\n";
print read_file($file);



