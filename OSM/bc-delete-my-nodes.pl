#!/bin/perl

# Finds and deletes nodes I created (since I'm "just testing" for now)

require "/usr/local/lib/bclib.pl";

# find my changesets
my($out, $err, $res) = cache_command("curl -s 'http://api.openstreetmap.org/api/0.6/changesets?display_name=barrycarter'", "age=3600");

# download the changesets
while ($out=~s/changeset id="(.*?)"//) {
  $changeset = $1;

  my($out, $err, $res) = cache_command("curl -s 'http://api.openstreetmap.org/api/0.6/changeset/$changeset/download'", "age=3600");

  # now find the nodes (need a fair amount of data on them to delete sigh)
  while ($out=~s/(<node.*?>)//) {
    $node=$1;
    $node=~/id="(.*?)"/;
    debug("CHANGESET: $changeset, NODE: $node");
    $id = $1;
    $cmd = "echo '<osm>$node</node></osm>' | curl -vv -d \@- -n -XDELETE http://api.openstreetmap.org/api/0.6/node/$id";
    my($out, $err, $res) = cache_command($cmd,"age=3600");
    debug("CMD: $cmd","OUT: $out","ERR: $err","RES: $res");
  }
}

# 11897676 = tricky
