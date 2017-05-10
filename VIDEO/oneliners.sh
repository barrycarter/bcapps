# I run these commands once and then # comment them out

# \ls fh2??.avi.*.jpg | perl -nle '/(\d+)\.jpg$/; print $1' | sort -nr | uniq -c | less

# 1845s max for season 2, 22 eps

# perl -le 'for $i ("01".."22") {for $j (0..1845) {$f=sprintf("fh2%02d.avi.%06d.jpg",$i,$j); unless (-f $f) {print "ln -s blank.jpg $f";}}}'

# perl -le 'for $j (0..1845) {$f=sprintf("fh2??.avi.%06d.jpg",$j); $o=sprintf("s2f%06d.jpg",$j); print "montage -background black -geometry 204x152 -tile 5x5 $f - | convert -border 2x4 - $o"}' > ses2.sh

# tac ses2.sh | parallel -j 5 &

ffmpeg -i s2f%06d.jpg season2.mp4
