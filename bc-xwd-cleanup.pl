#!/bin/perl

# Runs nightly and cleans up the previous days XWD files (as described below)
# Runs directly on bcmac

require "/usr/local/lib/bclib.pl";

# TODO: don't hardcode this
$date = "20150222";

print << "MARK";
cd /mnt/sshfs/XWD
mkdir $date
mv pic.$date:*.png $date
cd $date
MARK
;

# run tesseract and convert on all files in directory (convert to .pnm
# because ZPAQ compresses this most efficiently)

open(A,"|/usr/local/bin/parallel -j 20");

for $i (glob "*.png") {
  print A "/usr/local/bin/convert $i $i.pnm\n";
  # below automatically adds .txt extension, doesn't overwrite
  print A "/usr/local/bin/tesseract $i $i\n";
}

close(A);

