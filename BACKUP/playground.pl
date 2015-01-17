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

  # below directly from bc-total-bytes.pl
  my(%hash) = ();
  my(@data) = split(/\s+/, $_);

  for $i (@format) {$hash{$i} = shift(@data);}

  # rest of data is file type and file name (ignoring symlinks)
  for $i (@data) {
    if ($i=~/^\`(.*?)\'$/) {$hash{filename} = $1; last;}
    # this catenates filetype into a single word
    $hash{type}.=$i;
  }

  # dont backup directories (but empty files and links are fine)
  if ($hash{type}=~/directory/) {next;}

  debug("LINE: $_", "HASH",%hash);

  debug("TYPE: $hash{type}");

  $tot+= $hash{size};

  # NOTE: to avoid problems w/ filesizes > $limit, we add to chunk
  # first and THEN check for overage
  print A "$hash{filename}\n";
  print B $_;

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
