#!/bin/perl

# scans images using my ADF scanner

require "/usr/local/lib/bclib.pl";

# find USB address of my ADF scanner
%scanners = %{find_attached_scanners()};
# must quote these strings, otherwise interpreted as numbers
$usb = $scanners{"0x03f0"}{"0x1205"};
unless ($usb) {die "Scanner not attached";}

# scanning takes a while, so default alert me when done
defaults("xmessage=1");
my($out,$err,$res);

for (;;) {
  # no actual caching, since each image is different
  my($date) = `date +%Y%m%d.%H%M%S.%N`;
  chomp($date);
  # TODO: allow end user to choose resolution (600x600 not always needed)
  my($cmd) = qq%sudo scanimage --mode Color -d 'hp5590:$usb' --source "ADF" --resolution 300 > $date.ppm%;
  debug("CMD: $cmd");
  ($out,$err,$res) = cache_command2($cmd);
  debug("OER: $out/$err/$res");

  # on failure, remove file + end loop
  # (otherwise, push to list of files-to-convert)
  # testing if rm step is wise
  if ($res) {
#    system("rm $date.ppm");
    last;
  } else {
    push(@files, "$date.ppm");
    debug("SLEEPING 5s");
    sleep(5);
  }
}

fix_scanned_files(@files);

# given a list of files (presumably, but not necessarily, @files),
# convert PPM to JPG, rectify images, cut duplex images into single
# images and reduce resolution to 200

sub fix_scanned_files {
  my(@files) = @_;

  for $i (@files) {
    # scanned at 200 dpi, 8.5"x11"
    my($cmd1)="convert $i -geometry 1700x2200 -crop 1700x2200+0+0 -flip -flop $i.jpg";
    system($cmd1);
  }
}
