#!/bin/perl

# quick and dirty Perl script to grab information about a given
# longitude and latitude (given in that order)

require "/usr/local/lib/bclib.pl";

my($lng, $lat) = @ARGV;

# convert $lat/$lng to arcsecond boundary

$wlng = floor($lng*3600)/3600;
$elng = $wlng + 1/3600;

$slat = floor($lat*3600)/3600;
$nlat = $slat + 1/3600;

debug("LNG: $lng");

warn "TESTING"; exit(0);

my($server) = "http://ws.terramapadventure.com:8080/geoserver/";

my($wfs) = "wfs?service=wfs&version=2.0.0&request=GetFeature";

my($out, $err, $res);

($out, $err, $res) = cache_command2("curl '$server/$wfs&bbox=34,-107,36,-105&typeNames=TMA-YAMC:ne_10m_admin_1_states_provinces&propertyName=name_en' | tidy -xml");

debug("OUT: $out");

=item comments

Sample URL:

http://ws.terramapadventure.com:8080/geoserver/wfs?service=wfs&version=2.0.0&request=GetFeature&bbox=34,-107,36,-105&typeNames=TMA-YAMC:ne_10m_admin_1_states_provinces

=cut
