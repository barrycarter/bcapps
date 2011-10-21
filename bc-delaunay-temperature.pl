#!/bin/perl

# Uses Delaunay triangulation to map stuff, using average of vertex
# values (qhull does the work)

require "bclib.pl";

open(A,">/tmp/dela.txt");
print A "2\n20\n";

for $i (1..20) {
  print A rand()*1000," ",rand()*1000,"\n";
}

close(A);

system("qdelaunay i < /tmp/dela.txt");
