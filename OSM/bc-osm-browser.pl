#!/bin/perl

# text browser for OSM (openstreetmap.org)

require "/usr/local/lib/bclib.pl";

# debug(get_osm(35,-106));
# debug(get_osm(35.01,-105.99));

debug(parse_file(get_osm(35.09,-106.66)));

=item get_osm($lat, $lon)

Obtain AND cache (important!) the OSM data for the .01 degree box
whose lower left corner is $lat, $lon

$lat and $lon are truncated to 2 decimal places for caching

=cut

sub get_osm {
  my($lat, $lon) = @_;
  $lat = sprintf("%.2f", $lat);
  $lon = sprintf("%.2f", $lon);

  # where to store this
  my($sha) = sha1_hex("$lat,$lon");

  # .01 degree tiles -> 360*100*180*100 = ~648M tiles total, so
  # splitting into dirs
  $sha=~m%^(..)(..)%;
  my($dir) = "/var/tmp/OSM/cache/$1/$2";

  # does it already exist?
  if (-f "$dir/$sha") {return read_file("$dir/$sha");}

  # TODO: test that below works
  system("mkdir -p $dir");

  # and get the data
 my($cmd) = sprintf("curl -o $dir/$sha 'http://api.openstreetmap.org/api/0.6/map/?bbox=%.2f,%.2f,%.2f,%.2f'", $lon, $lat, $lon+.01, $lat+.01);

  my($out, $err, $res) = cache_command($cmd);
}

# parses the result of what the API sends us

sub parse_file {
  my($data) = @_;
  my(@nodes);

  

  # first, <node .../>
  while ($data=~s%<(node[^>]*/)>%%s) {
    my($node) = $1;

    # store node data in hash
    my(%node) = ();

    while ($node=~s/(\S+)\=\"(.*?)\"//) {
      $node{$1} = $2;
    }

    push(@nodes, {%node});

    debug("NODE:",%node);
  }

  # TODO: combine this w/ code above, redundant
  # now, <node...></node>
  while ($data=~s%<node(.*?)</node>%%s) {
    my($node) = $1;

    # store node data in hash
    my(%node) = ();

    while ($node=~s/(\S+)\=\"(.*?)\"//) {
      $node{$1} = $2;
    }

    debug("CHONK: $1");
  }


#  debug("NODES",@nodes);

}




