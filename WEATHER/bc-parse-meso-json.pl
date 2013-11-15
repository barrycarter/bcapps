#!/bin/perl

# Parses given file, the output of Mesonet's API

require "/usr/local/lib/bclib.pl";

my($all, $file) = cmdfile();
my($json) = JSON::from_json($all);

debug("KEYS", keys %{$json});

@reps = @{$json->{STATION}};

for $i (@reps) {

  my(%stathash) = ();
  # the non-observation station keys
  for $j (keys %{$i}) {
    if ($j eq "OBSERVATIONS") {next;}
    # TODO: ok to ignore these?
    if ($j eq "SENSOR_VARIABLES") {next;}
    $stathash{$j} = $i->{$j};
  }

  debug(var_dump("STATHASH", {%stathash}));

  # inverting observations to be an array of hashes (not a hash of arrays)
  @hashes = ();

  for $j (keys %{$i->{OBSERVATIONS}}) {
    # the list of observations for this variable
    my(@obs) = @{$i->{OBSERVATIONS}{$j}};
    for $k (0..$#obs) {
      $hashes[$k]{$j} = $obs[$k];
    }
  }

  $n++;
  debug(var_dump("HASHES($n)",\@hashes));

#  next;
#  warn "TSTING";
  # the dates/times of the observations
#  my(@datetimes) = @{$i->{OBSERVATIONS}{date_time}};
#  debug("DT",@datetimes);
}


