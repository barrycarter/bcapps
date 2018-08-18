#!/bin/perl

# converts a list of polygons (from "ogrinfo -al *.shp") to a
# Mathematica compatible list

require "/usr/local/lib/bclib.pl";

# print "{\n";

my($fid);

while (<>) {

  # keep track of fid to make things easier
  if (/^\s*fid\s*\(.*?\)\s*\=\s*(\d+)/i) {$fid = $1;}

  # aside from that, just the polygons
  unless (s/^\s*polygon\s*\(\((.*?)\)\)\s*$/$1/i) {next;}

  # this may not be an error, it may be the Caspian Sea
  # only row FID 148986 has this error, and I ignore it
  # TODO: don't ignore it
  if (/\(/ || /\)/) {
    warn("ROW: $fid contains internal parens");
    next;
  }

  # listify each coordinate
  # TODO: make sure flipping here is correct
  s/([0-9\.\-]+) ([0-9\.\-]+)/{$2,$1}/g;

  print "poly[$fid] = {$_};\n";
}

=item notes

10000: ok

100K: ok

1M:

Syntax::sntx: Invalid syntax in or before 
    "                                                                           
                                                     <<115420283>>              
                                                    ^"
     (line 148988 of
     "/home/user/20180724/land-polygons-complete-4326/land_polygons.m").

150K: same error as above

140-150K:

     (line 8989 of
     "/home/user/20180724/land-polygons-complete-4326/land_polygons.m").

148900-149000: 

Syntax::sntx: Invalid syntax in or before 
    "                                                                           
                                                   <<115420286>>                
                                                 ^"
     (line 89 of
     "/home/user/20180724/land-polygons-complete-4326/land_polygons.m").

148985-148995

=cut
