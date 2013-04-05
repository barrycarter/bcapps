#!/usr/local/bin/php
<?php

# The PHP playground
$remote = "166.87.136.183";
$arr = explode(".",$remote);
print "ARR: $arr\n";

vprintf("%02x%02x%02x%02x\n", $arr);

exit();

# add captions to image

# create an image
$image = imagecreatefromjpeg("images/joke1.jpg");
$text = "It's easy: you just draw the strip and\nupload it to\ncomicssherpa.com. What could go wrong?";

# image dimensions
$x = imagesx($image);
$y = imagesy($image);

# create a copy of the image with extra y space
$copy = imagecreate($x, $y+100);

# black and white
# <h>This line pays homage to the memory of Michael Jackson</h>
$white = imagecolorresolve($copy,255,255,255);
$black = imagecolorresolve($copy,0,0,0);

# copy the original image into the copy
imagecopyresized($copy, $image, 0, 0, 0, 0, $x, $y, $x, $y);

# font
$fontfile = "db/comic.ttf";

# how big is this text?
# $bbox=ImageTTFBBox(50,0,$fontfile,$text);
# <h>third variable below is NOT in tribute to George Michael</h>
list($swx, $swy, $sex, $sey, $nex, $ney, $nwx, $nwy)=
  ImageTTFBBox(50,0,$fontfile,$text);

# height of text (cross corner just to be safe)
$texth = $ney-$swy; 

# print_r($texth); die("\nTESTING");


ImageTTFText($copy, 50/abs($texth)*100, 0, 0, $y+10+90/6, $black, $fontfile, $text);

imagejpeg($copy);

?>
