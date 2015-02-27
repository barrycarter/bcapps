#!/bin/perl

# use images instead of text in fly text

# from http://tecfa.unige.ch/guides/utils/fly-use.html
# tiny (5x8), small (6x12), medium (7x13), large (8x16), giant (9x15)

print << "MARK";
new
size 800,600
setpixel 0,0,0,0,0
string 255,0,0,100,500,tiny,hello
# copy 50,60,0,0,50,50,/home/barrycarter/20140716/m228.gif.temp 
copy 50,60,0,0,50,50,/home/barrycarter/BCGIT/ASTRO/Earth_symbol.svg.gif
# copyresized -1,-1,-1,-1,500,500,550,550,/home/barrycarter/BCGIT/ASTRO/Earth_symbol.svg.png
# copyresized 550,550,600,600,0,0,50,50,/home/barrycarter/BCGIT/ASTRO/Earth_symbol.svg
# copyresized -1,-1,-1,-1,500,500,600,600,/home/barrycarter/BCGIT/ASTRO/Earth_symbol.svg
MARK
;
