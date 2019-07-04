#!/bin/perl

# A list of maps available from bc-mapserver.pl. Notes:

# For vector files, only the SHP file is given, but others are necessary
# For raster files, only the BIN (EHdr main file) is given, but others needed

our(%maps);

# the root for raster maps (as a squashfs) and naturalearth vector maps

our($rroot) = "/mnt/bcmapserver";

# TODO: this may change
our($vroot);

for $i ("/mnt/kemptown/NOBACKUP/EARTHDATA/NATURALEARTH/10m_cultural",
	"/mnt/volume_lon1_01/DATA/10m_cultural") {
  if (-d $i) {$vroot = $i;}
}

# TODO: could actually get a lot of this info from gdalinfo at startup

# TODO: check maps actually exist on startup

# TODO: add resolution for raster maps

$maps{climate} = {
   "description" => "TODO: add description",
   "source" => "TODO: add source",
   "processing" => "Converted from TIF to EHdr for speed",
};


$maps{landuse} = {
   "filename" => "$rroot/landuse.bin", "type" => "raster", "size" => "Byte",
   "description" => "TODO: add description",
   "source" => "TODO: add source",
   "processing" => "Converted from TIF to EHdr for speed"
};

$maps{popcount} = {
   "filename" => "$rroot/popcount.bin", "type" => "raster",
   "size" => "Float32",
   "description" => "TODO: add description",
   "source" => "TODO: add source",
   "processing" => "Converted from TIF to EHdr for speed"
};

$maps{popdensity} = {
   "filename" => "$rroot/popdensity.bin", "type" => "raster",
   "size" => "Float32",
   "description" => "TODO: add description",
   "source" => "TODO: add source",
   "processing" => "Converted from TIF to EHdr for speed"
};

# TODO: allow end user to choose attribute for vector maps?

$maps{timezone} = {
   "filename" => "$vroot/ne_10m_time_zones.shp",
   "type" => "vector", "size" => "Byte",
   "description" => "TODO: add description",
   "attribute" => "zone",
   "source" => "TODO: add source"
};

$maps{countries} = {
   "filename" => "$vroot/ne_10m_admin_0_countries.shp",
   "type" => "vector", "size" => "Int32",
   "description" => "TODO: add description",
   "attribute" => "NE_ID",
   "source" => "TODO: add source"
};

$maps{states} = {
   "filename" => "$vroot/ne_10m_admin_1_states_provinces.shp",
   "type" => "vector", "size" => "Int32",
   "description" => "TODO: add description",
   "attribute" => "gn_id",
   "source" => "TODO: add source"
};





# TODO: allow aliases like timezones -> timezone?

# using this a library so returning true

true;
