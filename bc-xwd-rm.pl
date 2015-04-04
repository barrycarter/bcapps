#!/bin/perl

# Another program that helps only me: I "xwd" my screen every minute,
# and convert the XWD to PNGs. I later convert the PNGs to PNMs and
# archive them using ZPAQ (ZPAQ compresses PNMs much better than it
# compresses PNGs), and also OCR the PNGs. This script removes files I
# no longer need (after the archive and OCR process)

# this program runs on bcunix and uses sshfs to access bcmac
# TODO: above is probably inefficient
require "/usr/local/lib/bclib.pl";

for $i (glob "/mnt/sshfs/XWD/*.zpaq") {
  debug("I: $i");
}
