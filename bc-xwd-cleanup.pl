#!/usr/bin/perl

# Runs nightly and cleans up the previous days XWD files (as described below)

require "/usr/local/lib/bclib.pl";

$date = $ARGV[0];

system("/usr/bin/renice 19 -p $$");
chdir("/home/user/XWD/");
system("mkdir $date; mv pic.$date:*.png $date");
chdir("/home/user/XWD/$date");
defaults("xmessage=1");

# run tesseract and convert on all files in directory (convert to .pnm
# because ZPAQ compresses this most efficiently)

# TODO: figure out optimal value here
open(A,"|parallel -j 5");

# TODO: exclude cases where result already exists!

for $i (glob "*.png") {

  # as of 1 Aug 2017, no longer convert to PNM
  # unless (-f "$i.pnm") {print A "convert $i $i.pnm\n";}
  # below automatically adds .txt extension, doesn't overwrite
  unless (-f "$i.txt" || -f "/home/user/XWD2OCR/$date/$i.txt") {
    print A "tesseract $i $i\n";
  }
}

close(A);

# and move tesseract files out of the way
system("mkdir /home/user/XWD2OCR/$date; mv *.txt /home/user/XWD2OCR/$date/")

# TODO: add zpaq'ing
