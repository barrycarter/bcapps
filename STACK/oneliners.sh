# perl script to slice world_shaded_43k.jpg 43200x21600 into 1600x800 chunks

# this still creates 27^2 = 729 images, so trying again with 4800x2400
# (xv has some limits, but I think 4800x2400 will fit)

# perl -le 'for ($x=0; $x<43200; $x+=1600) {for ($y=0; $y<21600; $y+=800) {print "convert -crop 1600x800+$x+$y world_shaded_43k.jpg world-$x-$y.jpg"}}'

perl -le 'for ($x=0; $x<43200; $x+=1600*3) {for ($y=0; $y<21600; $y+=800*3) {print "convert -crop 4800x2400+$x+$y world_shaded_43k.jpg world-$x-$y.jpg"}}'


