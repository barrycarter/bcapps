#!/bin/perl

use Geo::ShapeFile;
require "/usr/local/lib/bclib.pl";
 
my $shapefile = Geo::ShapeFile->new("/home/user/20190427/ne_10m_time_zones.shp");


# got make 3: 10, 12, 21
debug($shapefile->shapes_in_area(-107, 35, -106, 36));



die "TESTING";

for $i (1..$shapefile->shapes()) {

  debug("I: $i");

  my($shp) = $shapefile->get_shp_record($i);

  my($dbf) = $shapefile->get_dbf_record($i);

  my($shx) = $shapefile->get_shx_record($i);

  debug("SHP: $shp, DBF: $dbf, SHX: $shx");

#  Geo::ShapeFile::get_dbf_record($i);

#  Geo::ShapeFile::get_shx_record($i);

#   my($dbf) = Geo::ShapeFile::get_dbf_record ($i);
}


die "TESTING";
 
#  note that IDs are 1-based
foreach my $id (1 .. $shapefile->shapes()) {
  my $shape = $shapefile->get_shp_record($id);

  debug(var_dump("shape", $shape));

  # see Geo::ShapeFile::Shape docs for what to do with $shape
 
  my %db = $shapefile->get_dbf_record($id);
}
 
#  As before, but do not cache any data.
#  Useful if you have large files and only need to access
#  each shape once or a small nmber of times.
# my $shapefile = Geo::ShapeFile->new('roads', {no_cache => 1});
