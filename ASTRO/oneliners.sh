#!/bin/sh

\ls ~/SPICE/KERNELS/asc*.mx | perl -nle 'print "math -initfile $_ < /home/barrycarter/BCGIT/ASTRO/bc-pos-dump.m";'

exit;

# for real run, will remove -p from xargs
\ls /home/barrycarter/SPICE/KERNELS/asc*000.431*.bz2 | xargs -p -n 1 bc-dump-cheb.pl --planets=mercury,venus,earthmoon,mars,jupiter,saturn,uranus,sun

exit;

# printing out the list of conjunctions in "Mathematica" form, eg:
# List[2.1625297498230506`*^6, 0.008766346776571019`]
# this converts to y-m-d and degrees

perl -nle 'if(/null/i){next;} s/\`\*\^/e/g; s/^.*?\[(.*?),\s*//;my($date)=`j2d $1`;s/\`\].*$//;chomp($date);my($deg)=$_*180/3.1415926535897932385;if($deg>=5.5){next;};print "$date $deg"' venjupreg-*.txt

exit;

# list of north pole coords from north-pole-from-geocenter.txt.bz2
bzfgrep 'E+' north-pole-from-geocenter.txt.bz2 | perl -anle 'map(s/E/*10^/g, @F); print "{",join(", ",@F),"},"; sub BEGIN {print "list={";}; sub END {print "{}}; list = Drop[list,-1]"}' > /tmp/math.m

exit;

# this adds definitions for ephemeris values from the output of
# bc-header-values.pl (I need to edit the output before inserting it
# into README)

bc-header-values.pl | perl -nle 'if (/^(.)D(.)/) {print "$_ D$1 of $2 at epoch"} elsif (/^(.)(.):/) {print "$_ $1 position of $2 at epoch"}'

exit; 

bzcat north-pole-from-geocenter.txt.bz2 | perl -nle 'if (/^(.*\.500000+)/) {print "{$1,"} elsif (s/(^\s*)(\-?\d\..*)$/$2/) {s/\s+/,/g;s/E/*10^/g; print "{$_}},"} sub BEGIN {print "list={";} sub END {print "};"}' > /tmp/math.m

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


