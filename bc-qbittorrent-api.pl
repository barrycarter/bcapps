#!/bin/perl

# trivial program to add given trackers to given torrents by using
# qBitTorrent API

require "/usr/local/lib/bclib.pl";

# bad states (states we ignore)
my(%badstates) = list2hash("missingFiles", "pausedUP");

# list of trackers to add
my(@newtracks) = `egrep -v '^#' $bclib{home}/torrent-trackers.txt`;

# in format qbittorrent will understand
my($newtracks) = join("", @newtracks);
$newtracks=~s/\n+/%0A/g;

# extra dangling %0A

$newtracks=~s/%0A$//sg;

debug("NEWTRACKS: $newtracks");

# TODO: don't cache results
my($out, $err, $res) = cache_command2("curl http://127.0.0.1:9000/query/torrents", "age=3600");

my(@torrents) = @{JSON::from_json($out)};

for $i (@torrents) {

  # ignore torrents in these states
  if ($badstates{$i->{state}}) {next;}

  # get trackers
  ($out, $err, $res) = cache_command2("curl http://127.0.0.1:9000/query/propertiesTrackers/$i->{hash}", "age=3600");

  # post trackers
  ($out, $err, $res) = cache_command2("curl http://127.0.0.1:9000/command/addTrackers -d 'hash=$i->{hash}&urls=$newtracks'");

#  my(@trackers) = @{JSON::from_json($out)};

#  my($ntrackers) = scalar(@trackers);

#  debug("TRACKERS: $ntrackers");

}

