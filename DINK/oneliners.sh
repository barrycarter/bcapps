# convert BMPs I dont already have to PNG (not all of them ship w/
# dink?), some from http://www.rtsoft.com/dink/dinkgraphics.zip per
# http://www.dinknetwork.com/forum.cgi?MID=189738&Posts=9

find . -iname '*.bmp' | perl -nle '$orig=$_; s%^.*/%%; s/.BMP$//; unless (-f "/home/barrycarter/BCGIT/DINK/PNG/$_.PNG") {print "convert $orig -transparent white /home/barrycarter/BCGIT/DINK/PNG/$_.PNG"}'

# \ls *.BMP | perl -nle 's/\.BMP//; print "convert -transparent white $_.BMP $_.PNG"'

