# commands for I Dream of Jeanne seasoning

# link locally

# ls ~/MP4/I\ Dream\ of\ Jeannie/Season\ */*.avi | perl -nle 'if (/(\d+)x(\d+)/) {print "ln -s \"$_\" doj$1$2.avi"}' | sh

# grab a handful of images to get size
# ffmpeg -i doj101.avi -vsync vfr test.%06d.jpg

# size is 384x288 or 4:3 ratio

# we are going to do 6x6 here since up to 31 episodes per season, so 170x128

# ls *.avi | perl -nle 'print "ffmpeg -i $_ -vf \47select=not(mod(n\\,30)), scale=170:128\47 -vsync vfr $_.%06d.jpg"' > doj2frames.sh

# find longest episode (1511 frames)

# find . -iname '*.avi.*.jpg' | perl -nle '/(\d+)\.jpg$/; print $1' | sort -nr | uniq -c | less

# and largest episode number (31)

# ls doj*.avi | perl -nle '/(\d\d)\.avi/; print $1' | sort -nr | head


# create blank frames

# perl -le 'for $k (1..5) {for $i ("01".."31") {for $j (0..1511) {$f=sprintf("doj$k%02d.avi.%06d.jpg",$i,$j); unless (-f $f) {print "ln -s blank.jpg $f";}}}}'

# montage

# perl -le 'for $k (1..5) {for $j (0..1511) {$f=sprintf("doj$k??.avi.%06d.jpg",$j); $o=sprintf("s${k}f%06d.jpg",$j); print "montage -background black -geometry 170x128 -tile 6x6 $f - | convert -border 2x0 - $o"}}' > montage.sh









