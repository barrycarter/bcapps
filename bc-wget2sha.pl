#!/bin/perl

# "wget -m" stores files in a subdirectory structure. This is useful,
# but can create problems if the URL contains special characters, or
# if a URL is both a file and a directory. Example:
# www.directionsforme.org/index.php/directions/info/SOAPPL/00049022199118
# http://www.directionsforme.org/index.php/directions/info/SOAPPL/00049022199118/P60

# I instead store URLs as their sha1sum (of the URL, not the
# content). This program converts "wget -m" files to sha1 files

# --nomakedirs: don't make subdirectories of target, assume they exist

require "/usr/local/lib/bclib.pl";

# Splitting sha1 into 256^2 subdirectories to avoid over large directories
$target = "/mnt/sshfs/D4M3";

unless ($globopts{nomakedirs}) {
  for $i (0..255) {
    for $j (0..255) {
      $path = sprintf("%02x/%02x",$i,$j);
      $dir = "$target/$path";
      unless (-d $dir) {
	system("mkdir -p $dir");
      }
    }
  }
}

debug("DONE MAKING/CHECKING DIRS");

# this file contains the output of "find . -type f" from the directory
# where I ran "wget -m"
open(A,"/mnt/sshfs/DIRECTIONSFORME/allfiles.txt");

# to be doubly safe, note down where I put files (and run this when done)
open(B,">/mnt/sshfs/DIRECTIONSFORME/wget2sha.sh");

while (<A>) {
  chomp;
  # url is just http:// file except when wget adds "/index.html"
  $url = "http://$_";
  $url=~s/\/index.html$//is;
  # take sha1sum
  $sha = sha1_hex($url);

  # find subdir (but target filename is FULL sha1sum in case I decide
  # to rearrange directories)
  $sha=~/^(..)(..)/;
  $tfile = "$target/$1/$2/$sha";

  # if target file already exists, do nothing
  if (-f $tfile) {next;}

  print B "mv $_ $tfile\n";
#  debug("URL: $url, SHA: $sha, TFILE: $tfile");
}




