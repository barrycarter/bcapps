#!/bin/perl

# find "best" names for stars in HYG DB

require "/usr/local/lib/bclib.pl";

my(%stars);

open(A,"zcat $bclib{githome}/ASTRO/hygdata_v3.csv.gz|");

my(@head) = split(/,/,<A>);

while (<A>) {

  %hash = ();
  my(@vals) = split(/,/,$_);

  for $i (0..$#head) {$hash{$head[$i]} = $vals[$i];};

  my($id) = $hash{id};

  # copy fields directly form HYG

  for $j ("id", "x", "y", "z", "mag") {$stars{$id}{$j} = $hash{$j};}

  # try to get name

  if ($hash{proper}) {$stars{$id}{name} = $hash{proper}; next;}

  if ($hash{bayer}) {$stars{$id}{name} = "$hash{bayer}$hash{con}"; next;}
  if ($hash{flamsteed}) {$stars{$id}{name} = "$hash{flamsteed}$hash{con}"; next;}

  if ($hash{hip}) {$stars{$id}{name} = "HIP$hash{hip}"; next;}
  if ($hash{hd}) {$stars{$id}{name} = "HD$hash{hd}"; next;}
  if ($hash{gl}) {$stars{$id}{name} = "$hash{gl} (Gliese)"; next;}

  debug("WTF: $hash{gl}");

}

for $i (sort {$a <=> $b} keys %stars) {
#    print "stars[$i] = {name: \"$stars{$i}{name}\", id: $stars{$i}{id}, x: $stars{$i}{x}, y: $stars{$i}{y}, z: $stars{$i}{z}, mag: $stars{$i}{mag}};\n";
    print "stars[$i]={name:\"$stars{$i}{name}\",id:$stars{$i}{id},x:$stars{$i}{x},y:$stars{$i}{y},z:$stars{$i}{z},mag:$stars{$i}{mag}};\n";
#    print "stars[$i] ($stars{$i}{name}) $stars{$i}{mag}\n";
}







