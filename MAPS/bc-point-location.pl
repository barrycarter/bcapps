#!/bin/perl

# this uses the bc-mapserver.pl data (and more) to determine point
# based location; however, because the data is "raw" the results will
# be just plain weird

require "/usr/local/lib/bclib.pl";

# lng/lat on command line (in that order)
my($lng, $lat) = @ARGV;

# at level 21, the tile we're requesting is a 0.002 seconds of arc per pixel


# TODO: this is just a test URL to parse the data

my($test) = "http://ws.terramapadventure.com:22779/cmd=data&map=timezone&z=0&x=0&y=0";

my($out, $err, $res);

($out, $err, $res) = cache_command2("curl '$test'", "age=3600");

my($data) = JSON::from_json($out);

debug("OUT: ", keys %{$data}, $data->{data});

my(@arr) = map($_ = ord($_), split(//, $data->{data}));

debug(@arr);



