#!/bin/perl

# parses houses.txt.bz2 to provide "horoscope" changes

require "/usr/local/lib/bclib.pl";

# TODO: check initial state!
%state = ("S" => 1, "M" => 2, 1 => 1, 2 => 2, 4 => 2, 5 => 1, 6 => 6);

@planets = split(//, "SM12456");

open(A, "bzcat houses.txt.bz2|");

while (<A>) {

  if (rand() < 10**-5) {debug("STATUS: $_");}

  s/^\s*//;
  my(@f) = split(/\s+/, $_);
  my($ptime, $time, $delta) = (join(" ",@f[0..2]), $f[7], $f[8]);

  # interpret delta
  my($planet, $house) = split(//, $delta);

  my($check) = abs(hex($house)-hex($state{$planet}));

  # NOTE: turns out there are no bad lines, yay!
  unless ($check == 1 || $check == 11) {warn("BAD LINE: $_");}

  # print results
  # TODO: find better way to do this?
  my(@print) = @planets;
  map($_=$state{$_}, @print);
  my($print) = join("",@print);
  print "$ptime $print $time\n";

  debug("$planet going from $state{$planet} to $house");

  # TODO: check!
  $state{$planet} = $house;



#  debug("GOT: $_");
}
