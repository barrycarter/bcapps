#!/bin/perl

require "/usr/local/lib/bclib.pl";

# --dir: the dir for this backup (required) to keep it separate from others

# given an in-order list of files to backup as:
# stat -c "%s %Y %Z %d %i %F %N")
# break them into 500M chunks (not a magic number) for backing up
# also record what files are backed up (w/ info above); in future, I can
# fgrep -vf this list so I dont backup the same thing many times

unless ($globopts{dir}) {die "Usage: $0 --dir=subdirectory";}
my(@format) = ("size", "mtime", "ctime", "devno", "inode");
my($dir) = "/usr/local/etc/BACKUPS/$globopts{dir}";
my($limit) = 5e+8;
my($chunk) = 0;
my($tot);

# store filelist for tar, statlist for future excludes
# (could create one big statlist file but that could be ugly)
open(A,">$dir/filelist$chunk.txt")||die("Can't open, $!");
open(B,">$dir/statlist$chunk.txt")||die("Can't open, $!");

# the shell commands to run to tar, bzip, and encrypt the actual files
open(C,">$dir/runme.sh");
# TODO: this could probably be less redundant
# for the first chunk

while (<>) {

  # safe copy of line for statlist
  my($line) = $_;

  # this is ugly: convert true apos to ^A
  s/\\\'/\x01/g;

  my(%hash) = ();

  for $i (@format) {
    s/\s*(\d+)\s*//;
    $hash{$i} = $1;
  }

  # type and name (ignoring symlink targets for now)
  s/\s*(.*?)\s*\`/\`/;
  $hash{type} = $1;
  s/\`(.*?)\'\s*//;
  $hash{filename} = $1;

  if ($thunk && !($thunk=~/\->\s/)) {warn("BAD THUNK: $_");}

  # convert true apos back
  $hash{filename}=~s/\x01/\'/g;

  # dont backup directories (but empty files and links are fine)
  # TODO: add sockets and other weird types below, though they rarely come up
  if ($hash{type}=~/directory/) {next;}

  $tot+= $hash{size};

  # NOTE: to avoid problems w/ filesizes > $limit, we add to chunk
  # first and THEN check for overage
  print A "$hash{filename}\n";
  print B $line;

  # if we've gone over limit, move on to next chunk
  if ($tot>$limit) {
    $chunk++;
    debug("STARTING CHUNK: $chunk");
    $tot=0;
    close(A);
    close(B);
    open(A,">$dir/filelist$chunk.txt")||die("Can't open, $!");
    open(B,">$dir/statlist$chunk.txt")||die("Can't open, $!");
  }
}

# To actually use (example):
# sudo tar --bzip -cvf tarfile1.tbz --files-from=filelist1.txt >&! output1.txt&
# with pipe to gpg --encrypt if desired
# and check output1.txt for "tar:" errors
