#!/bin/perl

# scans images using my ADF scanner

require "/usr/local/lib/bclib.pl";
my($out,$err,$res);

for (;;) {
  if (++$count>=10) {warn "Testing limited to 10 docs"; last;}
  # no actual caching, since each image is different
  my($date) = `date +%Y%m%d.%H%M%S.%N`;
  chomp($date);
  my($cmd) = qq%sudo scanimage -d 'hp5590:libusb:001:005' --source "ADF" --resolution 600 > $date.ppm%;
  debug("CMD: $cmd");
  ($out,$err,$res) = cache_command2($cmd);

  # on failure, remove file + end loop
  # (otherwise, push to list of files-to-convert)
  if ($res) {
    system("rm $date.ppm");
    last;
  } else {
    push(@files, "$date.ppm");
  }
}

fix_scanned_files(@files);

# given a list of files (presumably, but not necessarily, @files),
# convert PPM to JPG, rectify images, cut duplex images into single
# images and reduce resolution to 200

sub fix_scanned_files {
  my(@files) = @_;

  for $i (@files) {
    # first image (this is 8.5" x 22" [since both sides scanned] at 200dpi)
    my($cmd1)="convert $i -geometry 1700x4400 -crop 1700x2200+0+0 -flip -flop $i.1.jpg";
    my($cmd2)="convert $i -geometry 1700x4400 -crop 1700x2200+0+2200 -flip -flop $i.2.jpg";
    system("$cmd1; $cmd2");
  }
}
