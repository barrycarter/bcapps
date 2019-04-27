#!/bin/perl

use Geo::ShapeFile;
require "/usr/local/lib/bclib.pl";
 
my $shapefile = Geo::ShapeFile->new('/home/user/NOBACKUP/EARTHDATA/NATURALEARTH/10m_physical/10m_lakes.shp');


 
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
