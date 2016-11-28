#!/bin/sh

# using cldr

fgrep mapZone common/supplemental/windowsZones.xml | perl -nle '/other="(.*?)".*type="(.*?)"/; for $i (split(/\s+/,$2)) {print "$i $1"}' | sort | uniq

exit; 

# timezones with filename (zdump.txt is just the output of "find /usr/share/zoneinfo -type f | xargs -n 1 zdump -v"

perl -anle '$F[0]=~s%/usr/share/zoneinfo/%%; print "$F[0] $F[-3]"' /home/barrycarter/20151102/zdump.txt | sort | uniq > tzfileabbrev.txt

exit;

# list of all timezones abbrevs used by zoneinfo
find /usr/share/zoneinfo -type f | xargs -n 1 zdump -v | perl -anle 'print $F[-3]' | sort | uniq > tzabbrevs.txt

exit;

# nothing really exciting here, manually labelling pictures but too
# long to fit in a single command line every time I change parameters

# the below converts must be run with "csh" not "sh" (TODO: why?)

convert -fill red \
-draw "text 933,302 Mercury" \
-draw "text 742,261 Mars" \
-draw "text 100,466 Venus" \
-draw "text 274,477 Uranus" \
-draw "text 950,250 Jupiter" \
~/STELLARIUM/stellarium-191.png ~/STELLARIUM/stellarium-191.ann.png
xv ~/STELLARIUM/stellarium-191.ann.png &

exit;

convert -fill red \
-draw "text 921,298 Mercury" \
-draw "text 719,256 Mars" \
-draw "text 163,409 Saturn" \
-draw "text 100,466 Venus" \
~/STELLARIUM/stellarium-184.png ~/STELLARIUM/stellarium-184.ann.png
xv ~/STELLARIUM/stellarium-184.ann.png &

exit;

convert -fill red \
-draw "text 300,27 Mercury" \
-draw "text 977,604 Venus" \
-draw "text 889,736 Uranus" \
-draw "text 488,309 Mars" \
~/STELLARIUM/stellarium-092.png ~/STELLARIUM/stellarium-092.ann.png 

exit;

# runs bc-find-under6.c (compiled in ~/bin/seps) for all combinations
# of visible planets' angular separations as viewed from Earth

# had to run this a second time (too many hits, had to up MAXWIN),
# thus the -f test

perl -le '@p=(1,2,4,5,6,7); for $i (0..$#p) {for $j ($i+1..$#p) {unless (-f "399-$p[$i]-$p[$j]-conjuncts.out") {print "/home/barrycarter/bin/seps 399 $p[$i] $p[$j] > 399-$p[$i]-$p[$j]-conjuncts.out"}}}'

exit;

# daily positions for all planets, all days (will use later) w Perl

\ls /home/barrycarter/SPICE/KERNELS/asc*.431.bz2 | perl -nle 'print "/home/barrycarter/BCGIT/ASTRO/bc-chebs-in-perl.pl $_ --planets=sun,mercury,venus,earthmoon,mars,jupiter,saturn,uranus,moongeo,neptune,pluto,nutate > $_.perl"'

exit;

# find minimal separations in daily files

\ls ~/SPICE/KERNELS/daily*.mx | perl -nle 'print "math -initfile $_ < /home/barrycarter/BCGIT/ASTRO/bc-conjunct-table.m";'

exit;

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


