#!/bin/perl

# CGI script: given an image URL, bounding box coordinates, and
# transparency, create a KMZ file of the image with given transparency

require "/usr/local/lib/bclib.pl";

# stolen directly from NWS' radar map and modified

<?xml version="1.0" encoding="utf-8"?>
<kml xmlns="http://earth.google.com/kml/2.0">
<Document>
<name>name-to-depend-on-params</name>
<GroundOverlay>
<name>name-to-depend-on-params</name>
<Icon>
<href>http://radar.weather.gov/ridge/RadarImg/N0R/ABX_N0R_0.gif</href>
</Icon>
<color>55ffffff</color>
<LatLonBox>
<north>37.5650361494585</north>
<south>32.726168961958</south>
<east>-104.17921697443</east>
<west>-109.457981178977</west>
</LatLonBox>
</GroundOverlay>
</Document>
</kml>


