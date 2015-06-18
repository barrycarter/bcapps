# convert BMPs I dont already have to PNG (not all of them ship w/
# dink?), some from http://www.rtsoft.com/dink/dinkgraphics.zip per
# http://www.dinknetwork.com/forum.cgi?MID=189738&Posts=9

# ended up redoing all of these because the graphics in
# dinkgraphics.zip are DIFFERENT From the graphics I extracted using
# ffrextract

find . -iname '*.bmp' | perl -nle '$orig=$_; s%^.*/%%; s/.BMP$//; print "convert $orig -transparent white /home/barrycarter/BCGIT/DINK/PNG/$_.PNG"'

# \ls *.BMP | perl -nle 's/\.BMP//; print "convert -transparent white $_.BMP $_.PNG"'

