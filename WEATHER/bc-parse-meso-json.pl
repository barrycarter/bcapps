#!/bin/perl

# Parses given file, the output of Mesonet's API

require "/usr/local/lib/bclib.pl";

my($all, $file) = cmdfile();
my($json) = JSON::from_json($all);

debug("KEYS", keys %{$json});

@reps = @{$json->{STATION}};

for $i (@reps) {
  debug(var_dump("HASH",$i));
  if ($n++ > 5) {die "TESTING";}
}
