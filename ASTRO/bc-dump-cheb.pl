#!/bin/perl

# reads and dumps the Chebyshev cofficients for a given
# asc[pm]*.431.bz2 file and for given planets, and stores them in a
# compact Mathematica "DumpSave" format

require "/usr/local/lib/bclib.pl";

my($file) = (@ARGV);
my(%planets) = list2hash(split(/\,/, $globopts{planets}));
debug("FILE: $file");
unless (-f $file && %planets) {die "Usage: $0 file --planets=list"};

# NOTE: have removed nutate since not using it here
my(@planets) = ("mercury:3:14:4", "venus:171:10:2", "earthmoon:231:13:2",
	    "mars:309:11:1", "jupiter:342:8:1", "saturn:366:7:1",
	    "uranus:387:6:1", "neptune:405:6:1", "pluto:423:6:1",
	    "moongeo:441:13:8", "sun:753:11:2");

# write directly to mathematica
open(B,"|math>/dev/null");

# we print info for all planets, not just ones we are dumping
for $i (@planets) {
  my(@l) = split(/:/, $i);
  for $j ("name", "pos", "num", "chunks") {
    $planetinfo{$i}{$j} = splice(@l,0,1);
    # this barely works because name is defined first
    print B "info[$planetinfo{$i}{name}][$j] = $planetinfo{$i}{$j};\n";
  }
}

open(A,"bzcat $file|");

# keep track of first/last JD
# <h>This is the glb and lub for the empty set</h>
my($mjstart,$mjend) = (+Infinity,-Infinity);

while (!eof(A)) {

#  if (++$count>10) {last;} # testing

  chomp;
  my($data) = "";
  # <h>this code should be taken out and shot</h>
  for (1..341) {$data.=<A>;}
  my(@data) = split(/\s+/s, $data);
  # TODO: might be more efficient to do this earlier
  map(s/d/*10^/i,@data);

  # first 5 coeffs are special
  my($blank, $chunknum, $tchunks, $jstart, $jend) = splice(@data,0,5);

  # keep track of max/min
  if ($jstart<$mjstart) {$mjstart=$jstart;}
  if ($jend>$mjend) {$mjend=$jend;}

  # TODO: allow for range checking here, if <$start next, if >$end last

  # error checking
  unless ($blank=~/^\s*$/) {warn "BAD BLANK: $data";}
  unless ($chunknum=~/^\d+$/) {warn "BAD CHUNKNUM: $data";}
  unless ($tchunks eq "1018") {warn "BAD TCHUNKS: $data";}

  # go thru planets
  for $planet (@planets) {
    # data elements belonging to this planet
    my($ncoeffs) = $planetinfo{$planet}{chunks}*3*$planetinfo{$planet}{num};
    my($coeffs) = join(", ",splice(@data,0,$ncoeffs));
    # NOTE: do this after above because we still need to slurp coefficients
    unless ($planets{$planetinfo{$planet}{name}}) {next;}
    print B "pos[$planetinfo{$planet}{name}][Rationalize[$jstart]]=Partition[Partition[Rationalize[{$coeffs},0],$planetinfo{$planet}{num}],3];\n";
    debug("pos[$planetinfo{$planet}{name}][Rationalize[$jstart]]=Partition[Partition[Rationalize[{$coeffs},0],$planetinfo{$planet}{num}],3];\n");
  }
}

close(A);

# dump file
my($df) = "$file.$globopts{planets}.mx";

print B << "MARK";
info[jstart] = $mjstart;
info[jend] = $mjend;
DumpSave["$df", {pos,info}];
MARK
;

close(B);
