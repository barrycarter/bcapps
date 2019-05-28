#!/bin/perl

# attempts to read a TIFF file without loading it into memory

require "/usr/local/lib/bclib.pl";


# this is a 100GB tiff!

# this fails with Can not read scanlines from a tiled image.

my($tiff) = "$bclib{home}/NOBACKUP/EARTHDATA/ELEVATION/SRTM1/SRTM1-TIFFS/elevation.tif";

use Graphics::TIFF ':all';
my $tif = Graphics::TIFF->Open($tiff, 'r' );
my $stripsize = $tif->StripSize;
for my $stripnum ( 0 .. $tif->NumberOfStrips - 1 ) {
    my $buffer = $tif->ReadEncodedStrip( $stripnum, $stripsize );
    # do something with $buffer
  }
$tif->Close;

