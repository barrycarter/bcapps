#!/bin/perl

# I use vlc's "snapshot" feature to take snapshots of my electric
# meter; however, VLC gives them stupid names like "elec45901.png"
# instead of naming them by timestamp (there is a setting on VLC to
# use timestamps, but it doesn't apply to this type of snapshot,
# sigh); this program fixes that oversight, using file mtime

require "/usr/local/lib/bclib.pl";
$maindir = "/mnt/sshfs/ELEC2013-VLC";

# if this directory doesn't exist, die
unless (-d $maindir) {die "$maindir DOES NOT EXIST";}

for $i (glob("$maindir/elec*.png")) {
  my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($i);
  # if size is 0, something is wrong
  if ($size==0) {
    write_file_new("$i: size 0", "/home/barrycarter/ERR/bcelecfix.err");
    die "0 size file";
  } else {
    system("rm /home/barrycarter/ERR/bcelecfix.err");
  }

  my($dir) = strftime("$maindir/%Y%m%d",localtime($mtime));
  unless (-d $dir) {system("mkdir $dir");}
  my($file) = strftime("elec%Y%m%d.%H%M%S.png",localtime($mtime));
  system("mv $i $dir/$file");
}

