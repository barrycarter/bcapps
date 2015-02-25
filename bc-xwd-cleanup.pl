#!/usr/bin/perl

# Runs nightly and cleans up the previous days XWD files (as described below)
# Runs directly on bcmac

# TODO: don't hardcode this
$date = "20150222";

chdir("/mnt/sshfs/XWD/");
system("mkdir $date; mv pic.$date:*.png $date");
chdir("/mnt/sshfs/XWD/$date");

# run tesseract and convert on all files in directory (convert to .pnm
# because ZPAQ compresses this most efficiently)

open(A,"|/usr/local/bin/parallel -j 20");

# TODO: exclude cases where result already exists!

for $i (glob "*.png") {
  unless (-f "$i.pnm") {print A "/usr/local/bin/convert $i $i.pnm\n";}
  # below automatically adds .txt extension, doesn't overwrite
  unless (-f "$i.txt") {print A "/usr/local/bin/tesseract $i $i\n";}
}

close(A);

# TODO: add zpaq'ing + move txt files out of way

