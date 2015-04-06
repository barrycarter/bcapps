#!/bin/perl

# Another program that helps only me: I "xwd" my screen every minute,
# and convert the XWD to PNGs. I later convert the PNGs to PNMs and
# archive them using ZPAQ (ZPAQ compresses PNMs much better than it
# compresses PNGs), and also OCR the PNGs. This script removes files I
# no longer need (after the archive and OCR process)

# this program runs on bcunix and uses sshfs to access bcmac
# TODO: above is probably inefficient
require "/usr/local/lib/bclib.pl";

# sshfs can be a little slow, so archiving...

# which archives do I have/
my($out,$err,$res) = cache_command2("echo /mnt/sshfs/XWD/*.zpaq","age=86400");
my(%zpaq,%dirs);
for $i (split(/\s+/,$out)) {
  if ($i=~m%/mnt/sshfs/XWD/(\d{8}).zpaq%) {
    $zpaq{$1}=1;
  }
}

# which directories still exist (no point in testing otherwise)
my($out,$err,$res) = cache_command2("find /mnt/sshfs/XWD/ -maxdepth 1 -mindepth 1 -type d","age=86400");
while ($out=~s%/mnt/sshfs/XWD/(\d{8})%%) {$dirs{$1}=1;}

# and which have both (ie, our final check list)
my(@flist);
for $i (keys %zpaq) {
  if ($dirs{$i}) {
    push(@flist,$i);
  }
}

for $i (@flist) {
  debug("I: $i");
  my(%hash);

  # the files I've archived
  my($out,$err,$res) = cache_command2("zpaq list /mnt/sshfs/XWD/$i.zpaq","age=86400");
  while ($out=~s%$i/pic\.($i:.*?)\.png\.pnm%%s) {$hash{zpaq}{$1} = 1;}

  # the files I've OCRd
  my($out,$err,$res)=cache_command2("find /mnt/sshfs/XWD2OCR/$i","age=86400");
  while ($out=~s%$i/pic\.($i:.*?)\.png\.txt%%s) {$hash{ocr}{$1} = 1;}

  # TODO: I can probably do this better...
  for $j (keys %{$hash{zpaq}}) {
    if ($hash{ocr}{$j}) {
      print "rm /mnt/sshfs/XWD/$i/pic.$j.png\n";
      print "rm /mnt/sshfs/XWD/$i/pic.$j.png.pnm\n";
    }
  }
}

print "echo recommend deleting empty dirs\n";

