#!/bin/perl

# Another program that helps only me: I "xwd" my screen every minute,
# and convert the XWD to PNGs. I later convert the PNGs to PNMs and
# archive them using ZPAQ (ZPAQ compresses PNMs much better than it
# compresses PNGs), and also OCR the PNGs. This script removes files I
# no longer need (after the archive and OCR process)

# this program runs on bcunix and uses sshfs to access bcmac
# TODO: above is probably inefficient
require "/usr/local/lib/bclib.pl";

# sshfs can be a little slow, so archiving
my($out,$err,$res) = cache_command2("echo /mnt/sshfs/XWD/*.zpaq","age=86400");
my(@zpaq) = split(/\s+/,$out);
map(s%/mnt/sshfs/XWD/(\d+).zpaq%$1%, @zpaq);

# which directories still exist (no point in testing otherwise)
my(@dirs);
my($out,$err,$res) = cache_command2("find /mnt/sshfs/XWD/ -maxdepth 1 -mindepth 1 -type d","age=86400");
while ($out=~s%/mnt/sshfs/XWD/(\d{8})%%) {push(@dirs,$1);}

my(@both) = 

debug("DIRS",@dirs,"ZPAQ",@zpaq);

die "TESTING";

for $i (@zpaq) {
  my(%hash);

  # grab the date from filename
  unless($i=~m%/mnt/sshfs/XWD/(.*?)\.zpaq%) {warn "BAD FILE: $i"; next;}
  my($i2) = $1;

  # the files I've archived
  my($out,$err,$res) = cache_command2("zpaq list $i","age=86400");
  while ($out=~s%$i2/pic\.($i2:.*?)\.png\.pnm%%s) {$hash{zpaq}{$1} = 1;}

  # the files I've OCRd
  my($out,$err,$res)=cache_command2("find /mnt/sshfs/XWD2OCR/$i2","age=86400");
  while ($out=~s%$i2/pic\.($i2:.*?)\.png\.txt%%s) {$hash{ocr}{$1} = 1;}

  # TODO: I can probably do this better...
  for $j (keys %{$hash{zpaq}}) {
    if ($hash{ocr}{$j}) {
      debug("J: /mnt/sshfs/XWD/$i2/$j.png");
    }
  }
}


