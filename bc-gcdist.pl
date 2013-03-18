#!/bin/perl

# Given n cities, find the pairwise distance between them (just a
# trivial wrapper around bc-cityfind.pl and gcdist())

require "/usr/local/lib/bclib.pl";

# quote the arguments and send to bc-cityfind.pl (passing them 'as is'
# removes one layer of quotes which turns "albuquerque nm" into two
# separate requests)
for $i (@ARGV) {$i="'$i'";}
my($cmd) = "bc-cityfind.pl ".join(" ",@ARGV);
$res = join("", `$cmd`);

# go thru responses
while ($res=~s%<response>(.*?)</response>%%is) {
  my($city) = $1;
  %hash = ();
  debug($city);
  while ($city=~s/<(.*?)>(.*?)<\/\1>//s) {$hash{$1}=$2;}
  push(@res, {%hash});
}

for $i (0..$#res) {
  for $j ($i+1..$#res) {

    # the latitudes/longitudes
    @latlon = ();
    for $k ($i,$j) {
      for $l ("latitude", "longitude") {
	push(@latlon, $res[$k]->{$l});
      }
    }

    my($dist) = gcdist(@latlon);
    print "$res[$i]->{city} to $res[$j]->{city}: $dist miles\n";
  }
}










