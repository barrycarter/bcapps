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
  # TODO: might be more efficient to do this earlier
  map(s/d/e/i,@data);

  # first 5 coeffs are special
  my($blank, $chunknum, $tchunks, $jstart, $jend) = splice(@data,0,5);

  # error checking
  unless ($blank=~/^\s*$/) {warn "BAD BLANK: $data";}
  unless ($chunknum=~/^\d+$/) {warn "BAD CHUNKNUM: $data";}
  unless ($tchunks eq "1018") {warn "BAD TCHUNKS: $data";}

  # go thru planets
  for $planet (@planets) {
    # number of data chunks for this planet (convenience variable)
    my($chunks) = $planetinfo{$planet}{chunks};
    # days per chunk (32 is hardcoded)
    my($days) = 32/$chunks;

    for $i (0..$chunks-1) {

      # determine coefficients
      for $j ("x","y","z"){
	my(@coeffs)=splice(@data,0,$planetinfo{$planet}{num});
      }

      # the start and end days for this chunk [for this planet], JD
      debug("JS: $jstart");
      my($jdstart) = $jstart+$i*$days;
      my($jdend) = $jdstart+$days;

      # loop through each day
      for $j (0..$days) {
	# position in interval
	my($pos) = -1+$j*2/$days;
	debug("DAY: $j, POS: $pos");
      }

      debug("$jdstart-$jdend");
      debug("I: $i");
      # coordinates



	  # TODO: this is just testing
#	  print "pos[$planetinfo{$planet}{name}][$chunknum][$i][$j] = {";
#	  print join(", ",@coeffs);
#	  print "};\n";
      }
    }
  }

