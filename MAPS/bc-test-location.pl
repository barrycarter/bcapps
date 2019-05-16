#!/bin/perl

# quick and dirty Perl script to grab information about a given
# longitude and latitude (given in that order)

# 15 May 2019: rewriting using only WMS, seems way easier

require "/usr/local/lib/bclib.pl";

my($url);
my($workspace) = "TMA-YAMC";

# the vector layers we can query

# TODO: consider merging layers esp "animals" layers

my(@vector) =
  (
   "ne_10m_admin_1_states_provinces",
   "ne_10m_admin_0_countries",
   "ne_10m_time_zones",
   "ne_10m_urban_areas"
  );

my(@raster) =
  (
   "Beck_KG_V1_present_0p0083",
   "ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7",
   "gpw_v4_population_count_rev11_2020_30_sec",
   "gpw_v4_population_density_rev11_2020_30_sec"
   );

# the hash mapes typename to the property we actually want

# ne_10m_urban_areas, while available, is not useful

my(%vector) =
  (
   "ne_10m_admin_1_states_provinces" => "name_en",
   "ne_10m_admin_0_countries" => "NAME_EN",
   "ne_10m_time_zones" => "tz_name1st"
   );

# TODO: giving up on animals for now
# the animal layers are consistent

# for $animal ("AMPHIBIANS", "CHONDRICHTHYES", "CONUS", "CORALS_PART1",
#	     "CORALS_PART2", "REPTILES", "MAMMALS") {
#  $vector{$animal} = "binomial";
# }



my(%raster) = (
   "Beck_KG_V1_present_0p0083" => "PALETTE_INDEX",
   "ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7" => "GRAY_INDEX",
   "gpw_v4_population_count_rev11_2020_30_sec" => "GRAY_INDEX",
   "gpw_v4_population_density_rev11_2020_30_sec" => "GRAY_INDEX"
);


# with WMS, we don't need to distinguish

my(%layers) = (
   "ne_10m_admin_1_states_provinces" => "name_en",
   "ne_10m_admin_0_countries" => "NAME_EN",
   "ne_10m_time_zones" => "tz_name1st",
   "Beck_KG_V1_present_0p0083" => "PALETTE_INDEX",
   "ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7" => "GRAY_INDEX",
   "gpw_v4_population_count_rev11_2020_30_sec" => "GRAY_INDEX",
   "gpw_v4_population_density_rev11_2020_30_sec" => "GRAY_INDEX"
);


my($lng, $lat) = @ARGV;

# convert $lat/$lng to arcsecond boundary

$wlng = floor($lng*3600)/3600;
$elng = $wlng + 1/3600;

$slat = floor($lat*3600)/3600;
$nlat = $slat + 1/3600;

my($server) = "http://ws.terramapadventure.com:8080/geoserver/";

my($wfs) = "wfs?service=wfs&version=2.0.0&request=GetFeature";

my($out, $err, $res);

for $i (keys %layers) {

#  $url = "$server/wfs?service=wfs&version=2.0.0&request=GetPropertyValue&bbox=$slat,$wlng,$nlat,$elng&typeNames=$workspace:$i&valueReference=$vector{$i}";

  # JSONic WMS URL (note lat/lng order is reversed)

  $url = "$server/wms?request=GetFeatureInfo&service=WMS&version=1.1.1&layers=$workspace:$i&styles=&srs=EPSG%3A4326&format=image%2Fpng&bbox=$wlng,$slat,$elng,$nlat&width=1&height=1&query_layers=$workspace:$i&info_format=application/json&propertyName=$layers{$i}&feature_count=1&x=1&y=1";

  debug("URL: $url");

  ($out, $err, $res) = cache_command2("curl '$url'", "age=3600");

  debug("OUT: $out, ERR: $err");

  my($hashref) = JSON::from_json($out);

  debug(var_dump("HR", $hashref));

  debug("FINAL", $hashref->{'features'}->[0]->{'properties'}->{$layers{$i}});

#  print "<$i>\n";

#  while ($out=~s%<$workspace:$vector{$i}>(.*?)</$workspace:$vector{$i}>%%) {
#    print "<value>$1</value>\n";
#  }

#  print "</$i>\n";
}


warn "TESTING"; exit(0);

# raster layers require WCS

for $i (keys %raster) {

#  $url = "$server/wcs?SERVICE=WCS&VERSION=1.1.1&REQUEST=DescribeCoverage&identifiers=$i";

#  $url = "$server/wcs?SERVICE=WCS&VERSION=1.1.1&REQUEST=GetCoverage&identifier=$i&valueReference=$raster{$i}&format=xml&boundingbox=$slat,$wlng,$nlat,$elng";

  $url = "$server/wcs?SERVICE=WCS&VERSION=1.1.1&REQUEST=GetCoverage&identifier=$i&format=xml&boundingbox=$slat,$wlng,$nlat,$elng";

  debug("URL: $url");
  ($out, $err, $res) = cache_command2("curl '$url' | tidy -xml", "age=3600");
  debug("RESULT: $out");

}

=item comments

Sample URL:

http://ws.terramapadventure.com:8080/geoserver/wfs?service=wfs&version=2.0.0&request=GetFeature&bbox=34,-107,36,-105&typeNames=TMA-YAMC:ne_10m_admin_1_states_provinces

http://ws.terramapadventure.com:8080/geoserver/TMA-YAMC/wcs?SERVICE=WCS&VERSION=1.1.1&REQUEST=DescribeCoverage&identifiers=ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7

=cut
