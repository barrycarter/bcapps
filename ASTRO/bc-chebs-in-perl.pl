#!/bin/perl

# planetary position stuff using Perl w/o Mathematica

# copies much initial code from bc-dump-cheb.pl

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

# we get info for all planets, not just ones we are dumping
for $i (@planets) {
  my(@l) = split(/:/, $i);
  my($name) = $l[0];
  for $j ("name", "pos", "num", "chunks") {
    $planetinfo{$name}{$j} = splice(@l,0,1);
  }

  # this turns out to be really helpful
  $planetinfo{$name}{daysperchunk} = 32/$planetinfo{$name}{chunks};

}

open(A,"bzcat $file|");

# big list of coeffs?
my(@coeffs);

# about 1m to read them all for a given 1000 year period
while (<A>) {
  if ($count++>100000) {warn "TESTING"; last;}
  s/D/E/g;
  while (s/(\-?0\.\d+E[+-]\d+)//) {push(@coeffs,$1);}
}

# for $i (0..$#coeffs) {debug("$i: $coeffs[$i]");}

debug("SIZE: $#coeffs");

for $i (0..10) {
  posxyz(2457266.5+$i,"mars");
}

=item posxyz($jd,$planet)

Determines the xyz position of $planet on $jd, provided that @coeffs
is defined for that period

TODO: @coeffs should have a better name and not be global?

=cut

sub posxyz {
  my($jd,$planet) = @_;

  # figure out 32 day chunk and days into that chunk
  my($chunk32) = int(($jd-$coeffs[0])/32);
  $jd -= 32*$chunk32+$coeffs[0];

  # which subchunk and where in subchunk (-1,1)
  my($subchunk) = int($jd/$planetinfo{$planet}{daysperchunk});
  $jd -= $subchunk*$planetinfo{$planet}{daysperchunk};
  my($t) = $jd/$planetinfo{$planet}{daysperchunk}*2-1;

  # find where in @coeffs the coefficients are for this time and planet
  my($findchunk) = 1018*$chunk32+$planetinfo{$planet}{pos}+3*$planetinfo{$planet}{num}*$subchunk-1;

  my(@xyz) = @coeffs[$findchunk..$findchunk+$planetinfo{$planet}{num}*3-1];

  debug("L: $#xyz");

#  debug("FC: $findchunk");
#  debug(@coeffs[$findchunk..$findchunk+3*$planetinfo{$planet}{num}]);


#  debug(@coeffs[$findchunk-1..$findchunk+2]);

#  debug("$chunk32 + $subchunk + $t");
}

die "TESTING";

=item chebyshevt([list],x)

Compute the ChebyshevT polynomial for list at x, where the nth coefficient
is given by the nth element of list

=cut

sub chebyshevt {
  my($lref,$x) = @_;
  my(@a) = @$lref;
  my($len) = $#a;
  my(@b);

  # compute the b(x)'s
  for $i (0..$len-1) {
    $b[$len-$i] = $a[$len-$i]+2*$x*$b[$len-$i+1]-$b[$len-$i+2];
  }

  return $a[0]+$x*$b[1]-$b[2];
}
