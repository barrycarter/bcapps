#!/usr/bin/perl

# Runs nightly and cleans up the previous days XWD files (as described below)
# Runs directly on bcmac

$date = $ARGV[0];

chdir("/mnt/extdrive2/XWD/");
system("mkdir $date; mv pic.$date:*.png $date");
chdir("/mnt/extdrive2/XWD/$date");

# run tesseract and convert on all files in directory (convert to .pnm
# because ZPAQ compresses this most efficiently)

# reduced to -j 1 (ie, no parallel processing) because of heavy CPU load
open(A,"|/usr/local/bin/parallel -j 5");

# TODO: exclude cases where result already exists!

for $i (glob "*.png") {
  unless (-f "$i.pnm") {print A "/usr/local/bin/convert $i $i.pnm\n";}
  # below automatically adds .txt extension, doesn't overwrite
  unless (-f "$i.txt" || -f "/mnt/extdrive2/XWD2OCR/$date/$i.txt") {
    print A "/usr/local/bin/tesseract $i $i\n";
  }
}

close(A);

# and move tesseract files out of the way
system("mkdir /mnt/extdrive2/XWD2OCR/$date; mv *.txt /mnt/extdrive2/XWD2OCR/$date/")

# TODO: add zpaq'ing
