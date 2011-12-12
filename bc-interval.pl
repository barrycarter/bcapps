#!/bin/perl

# Given a list of time intervals (like sample-data/intervals.txt),
# combine into shortest number of intervals

# Really just a one off I did for myself

require "bclib.pl";

# get data and loop through lines
my($data) = read_file("sample-data/intervals.txt");

for $i (split(/\n/,$data)) {
  # break line into fields, combine fields into dates, str2time
  my(@chunks) = split(/\s+/,$i);
  $d1 = str2time(join(" ",@chunks[0..2]));
  $d2 = str2time(join(" ",@chunks[3..5]));

  # my format has $d2 < $d1; if not true, worry
  if ($d2>=$d1) {die "BAD: $i";}

  # add interval to list of intervals, start time first
  push(@intervals, [$d2, $d1]);
}

# sort intervals by start time
@intervals = sort {@{$a}[0] <=> @{$b}[0]} @intervals;

# build final list of intervals, looking for overlaps

while (@intervals) {
  # first interval
  @int1 = @{shift(@intervals)};
  debug("INT1", @int1);

  # while intervals overlap this one, just change this one
  while (@intervals) {
    @int2 = @{shift(@intervals)};
    debug("INT2", @int2);
    if ($int2[0] <= $int1[1]) {
      debug("OVERLAP!");
      $int1[1] = $int2[1];
    } else {
      debug("NO OVERLAP");
      # interval doesn't overlap, push it back on stack
      unshift(@intervals, [@int2]);
      last;
    }
  }

  reset(@intervals);
}

reset(@intervals);

for $i (@intervals) {
  debug("INT: @{$i}[0] - @{$i}[1]");
}



