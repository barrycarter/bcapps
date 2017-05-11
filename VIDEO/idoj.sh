# commands for I Dream of Jeanne seasoning

# link locally

# ls ~/MP4/I\ Dream\ of\ Jeannie/Season\ */*.avi | perl -nle 'if (/(\d+)x(\d+)/) {print "ln -s \"$_\" doj$1$2.avi"}' | sh

# grab a handful of images to get size
# ffmpeg -i doj101.avi -vsync vfr test.%06d.jpg

# size is 384x288 or 4:3 ratio

# we are going to do 6x6 here since up to 31 episodes per season, so 170x128

ls *.avi | perl -nle 'print "ffmpeg -i $_ -vf \47select=not(mod(n\\,30)), scale=170:128\47 -vsync vfr $_.%06d.jpg"' > doj2frames.sh



