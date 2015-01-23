#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "$bclib{home}/bc-private.pl";

# --dir=$dir: dir for this backup (required) to keep it separate from others
# --stop=num: stop at this chunk

# given an in-order list of files to backup as:
# stat -c "%s %Y %Z %d %i %F %N")
# break them into 500M chunks (not a magic number) for backing up
# also record what files are backed up (w/ info above); in future, I can
# fgrep -vf this list so I dont backup the same thing many times

unless ($globopts{dir}) {die "Usage: $0 --dir=subdirectory filename";}
defaults("stop=9999999999");
my(@format) = ("size", "mtime", "ctime", "devno", "inode");
my($dir) = "/usr/local/etc/BACKUPS/$globopts{dir}";
dodie("chdir('$dir')");

if (glob("*")) {die "$dir already has files";}

# setting $tot to $limit so first run inside loop increments chunk
my($limit) = 5e+8;
my($tot) = $limit;

# the shell commands to run to tar, bzip, and encrypt the actual files
open(C,">$dir/runme.sh");
# TODO: this could probably be less redundant
# for the first chunk

while (<>) {

  # if we've gone over limit (or first run), move on to next chunk
  if ($tot>=$limit) {
    $chunk++;
    if ($chunk > $globopts{stop}) {last;}
    debug("STARTING CHUNK: $chunk");
    $tot=0;
    close(A);
    close(B);
    open(A,">$dir/filelist$chunk.txt")||die("Can't open, $!");
    open(B,">$dir/statlist$chunk.txt")||die("Can't open, $!");
    # command to tar this newly created chunk
    print C "(sudo tar --bzip -cvf - --files-from=filelist$chunk.txt | gpg -r $private{gpg}{user} --always-trust --encrypt -o gpgfile$chunk.gpg) 1> out$chunk.txt 2> err$chunk.txt\n";
  }

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
}

close(A); close(B); close(C);

# TODO: check out/err files for "tar:" errors when actually running;
