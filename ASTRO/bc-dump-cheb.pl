#!/bin/perl

# similar to bc-read-cheb.pl but dumps positional data by cleverly
# evaulating Chebyshev polynomials only at specific points

require "/usr/local/lib/bclib.pl";

my(@planets) = ("mercury:3:14:4", "venus:171:10:2", "earthmoon:231:13:2",
	    "mars:309:11:1", "jupiter:342:8:1", "saturn:366:7:1",
	    "uranus:387:6:1", "neptune:405:6:1", "pluto:423:6:1",
	    "moongeo:441:13:8", "sun:753:11:2", "nutate:819:10:4");

for $i (@planets) {
  my(@l) = split(/:/, $i);
  for $j ("name", "pos", "num", "chunks") {
    $planetinfo{$i}{$j} = splice(@l,0,1);
  }
}

open(A,"bzcat /home/barrycarter/SPICE/KERNELS/asc[pm]*.bz2|");

while (!eof(A)) {
  chomp;
  my($data) = "";
  # <h>this code should be taken out and shot</h>
  for (1..341) {$data.=<A>;}
  my(@data) = split(/\s+/s, $data);

  # first 5 coeffs are special
  my($blank, $chunknum, $tchunks, $jstart, $jend) = splice(@data,0,5);

  # error checking
  unless ($blank=~/^\s*$/) {warn "BAD BLANK: $data";}
  unless ($chunknum=~/^\d+$/) {warn "BAD CHUNKNUM: $data";}
  unless ($tchunks eq "1018") {warn "BAD TCHUNKS: $data";}

  # go thru planets
  for $planet (@planets) {
    debug("PLANET: $planet");
    # number of chunks for this planet
    for $i (1..$planetinfo{$planet}{chunks}) {
      # coordinates
      my(@coords) = ("x","y");
      unless ($planetinfo{$planet}{name} eq "nutate") {push(@coords,"z");}
      for $j (@coords) {
	my(@coeffs) = splice(@data, 0, $planetinfo{$planet}{num});
	  # TODO: this is just testing
	  print "pos[$planetinfo{$planet}{name}][$chunknum][$i][$j] = {";
	  print join(", ",@coeffs);
	  print "};\n";
      }
    }
  }
}
