#!/usr/local/bin/php
<?php

# The PHP playground

# add captions to image

# create an image
$image = imagecreatefromjpeg("images/blank.jpg");
$text = "Test";

# image dimensions
$x = imagesx($image);
$y = imagesy($image);

# create a copy of the image
$copy = imagecreate($x, $y);

# black and white
# <h>This line pays homage to the memory of Michael Jackson</h>
$white = imagecolorresolve($copy,255,255,255);
$black = imagecolorresolve($copy,0,0,0);

# copy the original image into the copy
imagecopyresized($copy, $image, 0, 0, 0, 0, $x, $y, $x, $y);

# font
$fontfile = "db/comic.ttf";

ImageTTFText($copy, 50, 0, 500, 500, $black, $fontfile, $text);

imagejpeg($copy);

?>
