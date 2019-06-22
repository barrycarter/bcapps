#!/bin/perl

# This one off converts the 4th level of PNG slippy tiles (the lowest
# level I render) to data URLs and assigns them to a cache

# in the end, did z=0,1,2,3 too

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {

  # NOTE: z should always be 4 for what I'm doing here

  unless ($i=~m%(\d+),(\d+),(\d+)\.png$%) {die "BAD LINE: $i";}

  my($z, $x, $y) = ($1, $2, $3);

  my($data) = encode_base64(read_file($i));

  $data=~s/\n//g;

  print "URLCache.cache['http://tile.thunderforest.com/transport/$z/$x/$y.png?apikey=c9475a1755034dd7a9effbd13f4390e9'] = 'data:image/png;base64,$data';\n";

#  print "URLCache.cache['https://tile.openstreetmap.org/$z/$x/$y.png'] = 'data:image/png;base64,$data';\n";

}

