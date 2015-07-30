#!/bin/perl

# Trivial script to parse Twilio HTML logs; for some reason, Twilio
# does NOT include recording URL/file in CSV file?!

require "/usr/local/lib/bclib.pl";

for $file (@ARGV) {
  my($all) = read_file($file);
  while ($all=~s%<tr class="">(.*?)</tr>%%is) {
    my($row) = $1;
#    debug("ROW: $row");
    my(@data) = ($row=~m%<td.*?>(.*?)</td>%gs);
#    my(DateDirectionFromToTypeStatusRecordingDuration);
    my($iddate, $direction, $from, $to, $type, $status, $recording, $duration) = @data;

    # cleanup/grep
    $iddate=~s/([\d\:]+)\s*UTC\s*<br>\s*([\d\-]+)//s;
    my($time) = "$2 $1";
    $iddate=~s%/calls/(.*?)\"%%;
    my($id) = $1;

    # duration in seconds
    my($durations);
    if ($duration=~/^\s*\-+\s*$/) {
      $durations=0;
    } elsif ($duration=~s/(\d+)\s*min\s*(\d+)\s*sec//) {
      $durations = $1*60+$2;
    } else {
      warn "BAD: $duration";
      $durations=-1;
    }

    # should be nothing (except spaces/hyphens) leftover after above (no hrs?)
    unless ($duration=~/^[\s\-]*$/) {warn "LEFTOVER: $duration";}

    # TODO: maybe make duration in pure seconds
    $duration=~s/\s+//g;
    $duration=~s/min/m/;
    $duration=~s/sec/s/;
    debug("$recording");

    # TODO: print id too, not just fields above


  }
}
