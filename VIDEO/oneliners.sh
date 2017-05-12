# I run these commands once and then # comment them out

# this frameifies all episodes (after fully converting names)

# NOTE: if doing this again, exclude Fuller House

# \ls fh*.avi fh*.mkv | perl -nle 'print "ffmpeg -i $_ -vf \47select=not(mod(n\\,30)), scale=204:152\47 -vsync vfr $_.%06d.jpg"' > temp.sh

# this is for fuller house (which go to 1693 frames and are mkv and
# need 341x192 to get 3x4 tiling (almost)

# \ls fh*.mkv | perl -nle 'print "ffmpeg -i $_ -vf \47select=not(mod(n\\,30)), scale=341:192\47 -vsync vfr $_.%06d.jpg"' > fuller.sh

# since this seems fairly parallelizeable

# parallel -j 5 < temp.sh &

# find . -iname 'fh*.avi.*.jpg' | perl -nle '/(\d+)\.jpg$/; print $1' | sort -nr | uniq -c | less

# Seasons 9 and 10 go to 1693 frames

# find . -iname 'fh*.mkv.*.jpg' | perl -nle '/(\d+)\.jpg$/; print $1' | sort -nr | uniq -c | less

# 1486 frames max all seasons, 22-24 eps (13 for Seasons 9 and 10)

# this unnecessarily, but harmlessly, creates frames for nonexistent episodes

# perl -le 'for $k (1..10) {for $i ("01".."24") {for $j (0..1486) {$f=sprintf("fh$k%02d.avi.%06d.jpg",$i,$j); unless (-f $f) {print "ln -s blank.jpg $f";}}}}'

# TODO: above should be fixed to 1..8 since no AVIs for 9 and 10

# special for seasons 9-10

# perl -le 'for $k (9..10) {for $i ("01".."13") {for $j (0..1693) {$f=sprintf("fh$k%02d.mkv.%06d.jpg",$i,$j); unless (-f $f) {print "ln -s blank.jpg $f";}}}}'

# NOTE: had to later fix seasons 9 and 10 since these are mkv.jpg not avi.jpg

# perl -le 'for $k (1..10) {for $j (0..1486) {$f=sprintf("fh$k??.avi.%06d.jpg",$j); $o=sprintf("s${k}f%06d.jpg",$j); print "montage -background black -geometry 204x152 -tile 5x5 $f - | convert -border 2x4 - $o"}}' > all.sh

# special montage for seasons 9 and 10 (TODO: fix above)

# 340 below to avoid odd number and add border, sigh
# this wont montage 13th episode of each season but ok w that
perl -le 'for $k (9..10) {for $j (0..1693) {$f=sprintf("fh$k??.mkv.%06d.jpg",$j); $o=sprintf("s${k}f%06d.jpg",$j); print "montage -background black -geometry 340x192 -tile 3x4 $f - | convert -border 2x0 - $o"}}' > fuller2.sh

# parallel -j 5 < all.sh &

# ffmpeg -i s%df%06d.jpg all.mp4

# TODO: accidentally deleted some season 1 jpegs with bad mask rm, but
# probably dont care at this point

# cheat way to delete all black montages

find . -size 6686c -iname 's?f*.jpg' | xargs rm
