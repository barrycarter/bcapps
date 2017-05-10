# I run these commands once and then # comment them out

# this frameifies all episodes (after fully converting names)

# \ls fh*.avi fh*.mkv | perl -nle 'print "ffmpeg -i $_ -vf \47select=not(mod(n\\,30)), scale=204:152\47 -vsync vfr $_.%06d.jpg"' > temp.sh

# since this seems fairly parallelizeable

# parallel -j 5 < temp.sh &

# find . -iname 'fh*.avi.*.jpg' | perl -nle '/(\d+)\.jpg$/; print $1' | sort -nr | uniq -c | less

# 1486 frames max all seasons, 22-24 eps (13 for Seasons 9 and 10)

# this unnecessarily, but harmlessly, creates frames for nonexistent episodes

# perl -le 'for $k (1..10) {for $i ("01".."24") {for $j (0..1486) {$f=sprintf("fh$k%02d.avi.%06d.jpg",$i,$j); unless (-f $f) {print "ln -s blank.jpg $f";}}}}'

perl -le 'for $k (1..10) {for $j (0..1486) {$f=sprintf("fh$k??.avi.%06d.jpg",$j); $o=sprintf("s${k}f%06d.jpg",$j); print "montage -background black -geometry 204x152 -tile 5x5 $f - | convert -border 2x4 - $o"}}' > all.sh

parallel -j 5 < all.sh &

# ffmpeg -i s2f%06d.jpg season2.mp4
