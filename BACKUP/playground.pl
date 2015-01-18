#!/bin/perl

require "/usr/local/lib/bclib.pl";

# given an in-order list of files to backup as:
# stat -c "%s %Y %Z %d %i %F %N")
# break them into 500M chunks (not a magic number) for backing up
# also record what files are backed up (w/ info above); in future, I can
# fgrep -vf this list so I dont backup the same thing many times

my(@format) = ("size", "mtime", "ctime", "devno", "inode");
my($dir) = "/usr/local/etc/BACKUPS/";
my($limit) = 5e+8;


my($chunk) = 0;
my($tot);

# store filelist for tar, statlist for future excludes
# (could create one big statlist file but that could be ugly)
open(A,">$dir/filelist$chunk.txt")||die("Can't open, $!");
open(B,">$dir/statlist$chunk.txt")||die("Can't open, $!");

while (<>) {

  # safe copy of line for statlist
  my($line) = $_;

  # below no longer from bc-total-bytes.pl, must fix that
  my(%hash) = ();

  for $i (@format) {
    s/\s*(\d+)\s*//;
    $hash{$i} = $1;
  }

  # type and name (ignoring symlink targets for now)
  s/\s*(.*?)\s*\`/\`/;
  $hash{type} = $1;
  # TODO: does this fail on files with embedded apostrophes?
  s/\`(.*?)\'\s*//;
  $hash{filename} = $1;

  if ($thunk && !($thunk=~/\->\s/)) {warn("BAD THUNK: $_");}

  # dont backup directories (but empty files and links are fine)
  if ($hash{type}=~/directory/) {next;}

  $tot+= $hash{size};

  # NOTE: to avoid problems w/ filesizes > $limit, we add to chunk
  # first and THEN check for overage
  print A "$hash{filename}\n";
  print B $line;

  # if we've gone over limit, move on to next chunk
  if ($tot>$limit) {
    $chunk++;
    $tot=0;
    close(A);
    close(B);
    open(A,">$dir/filelist$chunk.txt")||die("Can't open, $!");
    open(B,">$dir/statlist$chunk.txt")||die("Can't open, $!");
  }
}

# To actually use (example):
# sudo tar --bzip -cvf tarfile1.tbz --files-from=filelist1.txt >&! output1.txt&
# and check output1.txt for "tar:" errors
