#!/bin/perl

use Geo::ShapeFile;
require "/usr/local/lib/bclib.pl";
 
my $shapefile = Geo::ShapeFile->new("/home/user/20190427/ne_10m_time_zones.shp");

# this may or may not help individual shapes
$shapefile->build_spatial_index();

my(@shapes);

for $i (1..$shapefile->shapes()) {
  my($shape) = $shapefile->get_shp_record($i);
  $shape->build_spatial_index(0);
  $shapes[$i] = $shape;
  debug($shape->contains_point(new Geo::ShapeFile::Point(X=>1,Y=>2)));
  debug("I: $i, SHAPE: $shape");
}

for $i (0..255) {
  for $j (0..255) {

    my($lng) = -107+$j/3600;
    my($lat) = 35 + $i/3600;
    my($pt) = new Geo::ShapeFile::Point(X => $lng, Y => $lat);

    for $k (1..$#shapes) {
#      debug("K: $k, SHAPE: $shapes[$k]");
      if ($shapes[$k]->contains_point($pt, 1)) {
	debug("$i $j $k");
      }
    }
  }
}

die "ETSTING";


# looking at actual shapes

my($shape) = $shapefile->get_shp_record(1);

debug("SHAPE: $shape");

debug($shape->points());

die "TESTING";

# got make 3: 10, 12, 21
debug($shapefile->shapes_in_area(-107, 35, -106, 36));

my(@l);

debug("START", time());

# with below, can generate 255 x 255 in 5.43s still too slow but better
# without build_spatial_index, takes so long I aborted it

for $i (0..255) {
  for $j (0..255) {

    # TODO: this is wrong, uses bounding boxes
    @l = $shapefile->shapes_in_area(
      -107+$i/3600, 35+$j/3600, -107+($i+1)/3600, 35+($j+1)/3600
    );
    print "$i $j ",join(",",@l),"\n";
  }
}

debug("END", time());

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
