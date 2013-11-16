#!/bin/perl

# A simple wrapper around ccextractor that lets me "cc rip" my DVDs
# --dvd=name: name of the DVD (required)

require "/usr/local/lib/bclib.pl";
if ($>) {die("Must be root");}
# alert when done
defaults("xmessage=1");
# TODO: writing these to a "temp" directory for now
$homedir = "/home/barrycarter/20131115";

unless ($globopts{dvd}) {die "--dvd=name required";}

# allow time for mount to settle
for (;;) {
  system("mount /dev/sr0 /mnt/cdrom");
  if (bc_check_mount("/mnt/cdrom")==0) {last;}
  sleep 1;
  if (++$n>10) {die "CANNOT MOUNT, EVEN AFTER ~10 TRIES";}
}

for $i (glob "/mnt/cdrom/VIDEO_TS/*.VOB") {
  $o = $i;
  $o=~s/^.*\///;
  my($cmd) = "/root/build/ccextractor.0.67/linux/ccextractor -o $homedir/$globopts{dvd}-$o $i";
  print "RUNNING: $cmd\n";
  system($cmd);
}

system("eject");
