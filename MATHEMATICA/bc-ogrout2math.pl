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

  if (/\(/ || /\)/) {
    warn("ROW: $fid contains internal parens");
  }

  # listify each coordinate
  s/([0-9\.\-]+) ([0-9\.\-]+)/{$1,$2}/g;
  debug("FID: $fid");

  print "poly[$fid] = {$_};\n";

  # the form above appears to crash (too many regexs?), this might be
  # slower but should work better
  # below is too slow!
#  while (s/([0-9\.\-]+) ([0-9\.\-]+)/{$1,$2}/) {}

  # something's wrong, so only printing some polygons
#  $count++;

#  if ($count < 148985) {next;}
#  if ($count > 148995) {last;}

}

# print "}\n";

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
