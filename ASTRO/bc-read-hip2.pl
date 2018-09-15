#!/bin/perl

# Reads the Hipparcos 2 catalog

require "/usr/local/lib/bclib.pl";

while (<>) {

  # TODO: several variations of below fail, why?
  #  my($id) = column_data($_, [0,1,2,3,4,5,6,7]);

#  debug("LINE: $_");
  my($id) = get_chars($_, 1, 6);
  my($par) = get_chars($_, 44, 50);

  debug("ID: $id, PAR: $par");
}

# this version is slightly different from bc-tyc2db.pl
# maybe add to bclib.pl carefully
sub get_chars {
  my($str,$x,$y) = @_;
  return substr($str,$x-1,$y-$x+1);
}
