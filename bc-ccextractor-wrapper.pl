#!/bin/perl

# A simple wrapper around ccextractor that lets me "cc rip" my DVDs
# --dvd=name: name of the DVD (required)

require "/usr/local/lib/bclib.pl";
# alert when done
defaults("xmessage=1");
# TODO: writing these to a "temp" directory for now
$homedir = "/home/barrycarter/20131115";

unless ($globopts{dvd}) {die "--dvd=name required";}

# this should already be done, but can't hurt
system("sudo mount /dev/sr0 /mnt/cdrom");


for $i (glob "/mnt/cdrom/VIDEO_TS/*.VOB") {
  $o = $i;
  $o=~s/^.*\///;
  my($cmd) = "/root/build/ccextractor.0.67/linux/ccextractor -o $homedir/$globopts{dvd}-$o $i";
  print "RUNNING: $cmd\n";
  system($cmd);
}

system("sudo eject");
