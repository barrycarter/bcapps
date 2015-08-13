#!/bin/perl

# similar to bc-read-cheb.pl but dumps positional data by cleverly
# evaulating Chebyshev polynomials only at specific points

require "/usr/local/lib/bclib.pl";

# NOTE: have removed nutate since not using it here
my(@planets) = ("mercury:3:14:4", "venus:171:10:2", "earthmoon:231:13:2",
	    "mars:309:11:1", "jupiter:342:8:1", "saturn:366:7:1",
	    "uranus:387:6:1", "neptune:405:6:1", "pluto:423:6:1",
	    "moongeo:441:13:8", "sun:753:11:2");

for $i (@planets) {
  my(@l) = split(/:/, $i);
  for $j ("name", "pos", "num", "chunks") {
    $planetinfo{$i}{$j} = splice(@l,0,1);
    # this barely works because name is defined first
    print "info[$planetinfo{$i}{name}][$j] = $planetinfo{$i}{$j};\n";
  }
}

# limiting to "current" eon for testing
# open(A,"bzcat /home/barrycarter/SPICE/KERNELS/asc[pm]*.bz2|");
open(A,"bzcat /home/barrycarter/SPICE/KERNELS/ascp02000.431.bz2|");

while (!eof(A)) {
  chomp;
  my($data) = "";
  # <h>this code should be taken out and shot</h>
  for (1..341) {$data.=<A>;}
  my(@data) = split(/\s+/s, $data);
#  debug("DATA",@data);
  # TODO: might be more efficient to do this earlier
  map(s/d/*10^/i,@data);

  # first 5 coeffs are special
  my($blank, $chunknum, $tchunks, $jstart, $jend) = splice(@data,0,5);

  # error checking
  unless ($blank=~/^\s*$/) {warn "BAD BLANK: $data";}
  unless ($chunknum=~/^\d+$/) {warn "BAD CHUNKNUM: $data";}
  unless ($tchunks eq "1018") {warn "BAD TCHUNKS: $data";}

  # go thru planets
  for $planet (@planets) {
    # data elements belonging to this planet
    my($ncoeffs) = $planetinfo{$planet}{chunks}*3*$planetinfo{$planet}{num};
    my($coeffs) = join(", ",splice(@data,0,$ncoeffs));
    print "pos[$planetinfo{$planet}{name}][Rationalize[$jstart]]=Partition[Partition[Rationalize[{$coeffs},0],$planetinfo{$planet}{num}],3];\n";
  }
}
