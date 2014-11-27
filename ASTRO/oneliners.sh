#!/bin/sh

bzcat north-pole-from-geocenter.txt.bz2 | perl -nle 'if (/^(.*\.500000+)/) {print "{$1,"} elsif (s/(^\s*)(\-?\d\..*)$/$2/) {s/\s+/,/g;s/E/*10^/g; print "{$_}},"} sub BEGIN {print "list={";} sub END {print "};"}' > /tmp/math.m

exit;

# list of north pole coords from north-pole-from-geocenter.txt.bz2
bzfgrep 'E+' north-pole-from-geocenter.txt.bz2 | perl -anle 'map(s/E/*10^/g, @F); print "{",join(", ",@F),"},"; sub BEGIN {print "list={";}; sub END {print "{}}; list = Drop[list,-1]"}' > /tmp/math.m

exit;

# add decimal data to some-array-data.txt (am I really including my
# lib for each line below? weird, but it seems to work)

perl -nle 'require "/usr/local/lib/bclib.pl"; if (/\47([\-0-9A-F\^]*?)\47/) {print "$_ (",ieee754todec($1),")"} else {print $_;}' some-array-data.txt


exit;

# add hex values to planet-ids.txt (upcase to match NASA)

perl -anle '$str=uc(unpack("H8", pack("N", $F[0]))); $str=~s/^0+//; print "$str $_"' planet-ids.txt

exit;

# given a saved HORIZONS page, find the data and x coordinate (only
# for Albuquerque/geocenter stuff right now)


