#!/bin/perl

# Expanding the boundaries of uselessness, this program takes the
# results of a Bernalillio County property search
# (http://www.bernco.gov/property-tax-search/) and creates an iMacro
# that visits (BUT DOES NOT DOWNLOAD) each result. Running tcpflow or
# something similar will download the results

# NOTE: This assumes you are on the results page of an actual search,
# and that browser "BACK" (after you visit a listing) takes you to
# back to the list of matches

require "/usr/local/lib/bclib.pl";

while (<>) {
  unless (/id\=\"(ctl.*?_parcel)\"/) {next;}
  $link{$1}=1;
}

print "VERSION BUILD=8240212 RECORDER=FX\nTAB T=1\n";

# the PAUSE appears to be necessary though I have no idea why
for $i (sort keys %link) {print "TAG POS=1 TYPE=A ATTR=ID:$i\nPAUSE\n\nBACK\n";}

