#!/bin/perl

# Uses some-array-data.txt to show which files provide distances
# between which pairs of objects

require "/usr/local/lib/bclib.pl";

# read planet names
for $i (`fgrep -v '#' $bclib{githome}/ASTRO/planet-ids.txt`) {
  chomp($i);
  $i=~s/^(\d+)\s+//;
  my($id) = $1;
  $name{$id} = $i;
  # replace leading digits
  $name{$id}=~s/^(\d)/x$1/;
}

my(@all) = split("\n--\n", read_file("$bclib{githome}/ASTRO/some-array-data.txt"));

for $i (@all) {
  # codes_300ast_20100725.xsp contains osculating elements, not body-to-body?
  if ($i=~/codes_300ast_20100725.xsp/) {next;}

  # 1st row = which array, 5th row = target, 6th row = source
  my(@data) = split(/\n/, $i);

  # file and array
  $data[0]=~s/^(.*?):BEGIN_ARRAY (\d+)//||warn("BAD ROW: $data[0]");
  my($file, $idx) = ($1, $2);

  # target
  $data[4]=~/'(.*?)'/;
  my($target) = $1;

  # source
  $data[5]=~/'(.*?)'/;
  my($source) = $1;

  # two bodies may have positional data in multiple files/arrays
  $file=~s/\.xsp//;
  $file=~s/\-//g;
  push(@{$edge{$source}{$target}}, "x$file,$idx");

  # to compactify graph
  $graph{$source}{child}{"$file:$target"} = 1;
  $graph{$target}{parent}{"$file:$source"} = 1;
}

# find nodes w/ same parents/children and edge names
# TODO: in theory, could do this multiple times to "super compactify"
for $i (sort keys %graph) {
  # children, with edges
  # TODO: could/should do this with hashes, not commas/semicolons
  my($children) = join(",",sort keys %{$graph{$i}->{child}});
  my($parents) = join(",",sort keys %{$graph{$i}->{parent}});
  # record nodes that have same children and parents
  $pc{"$children;$parents"}{$i} = 1;
}

# combine by parents/children
for $i (sort keys %pc) {
  my($c,$p) = split(";", $i);
  debug("C: $c, p: $p");

#  debug("$i:", sort keys %{$pc{$i}});
}

die "TESTING";

print "digraph x {\n";

for $i (keys %edge) {
  for $j (keys %{$edge{$i}}) {
    $source = join(",", @{$edge{$i}{$j}});
    debug("SRC: $source");
    my($from) = $name{hex($i)};
    my($to) = $name{hex($j)};
    print qq%"$from" -> "$to" [label=$source]\n%;
#    print qq%"$from" -- "$to" [label=$source]\n%;
  }
}

print "};\n";

# pipe output to:
# dot -Tpng -Nshape=record | display -
# twopi -Tpng -Nshape=box -Nheight=0.01 -Nwidth=0.05 -Nfontsize=8 -Efontsize=8 -Goverlap=scale
# twopi -Tpng -Nshape=record -Nheight=0.1 -Nfixedsize=1 -Nfontsize=6 -Efontsize=0 -Granksep=2 -Earrowsize=.25 -Goverlap=true



