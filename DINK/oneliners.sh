# alpha: run this once from /usr/share/dink/dink to create transparent
# JPG versions of all BMPs (note the resulting files end in .BMP.jpg)

find graphics -iname '*.bmp' | perl -nle 'unless (-f "$_.jpg") {print "convert $_ -transparent white $_.jpg"}'

exit; 

# find all used sprite numbers in all mods to date (which is actually
# fairly pointless)

find . -iname 'dink.ini' -print0 | xargs -0 egrep -ih '^load_sequence' | perl -anle 'print $F[2]' | sort -n | uniq > used.txt

exit;

# convert BMPs I dont already have to PNG (not all of them ship w/
# dink?), some from http://www.rtsoft.com/dink/dinkgraphics.zip per
# http://www.dinknetwork.com/forum.cgi?MID=189738&Posts=9

# ended up redoing all of these because the graphics in
# dinkgraphics.zip are DIFFERENT From the graphics I extracted using
# ffrextract

find . -iname '*.bmp' | perl -nle '$orig=$_; s%^.*/%%; s/.BMP$//; print "convert $orig -transparent white /home/barrycarter/BCGIT/DINK/PNG/$_.PNG"'

# \ls *.BMP | perl -nle 's/\.BMP//; print "convert -transparent white $_.BMP $_.PNG"'

