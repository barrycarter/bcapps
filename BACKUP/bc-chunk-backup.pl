#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "$bclib{home}/bc-private.pl";

# --stop=num: stop at this chunk

# see README for file format

defaults("stop=9999999999");

# filetypes we ignore
my(%ignore) = list2hash("directory", "fifo", "socket", 
			"character special file", "block special file");

# types we accept
my(%accept) = list2hash("regular empty file", "regular file", "symbolic link");

# TODO: maybe allow files to be created in alternate dir
my($dir) = ".";

# setting $tot to $limit so first run inside loop increments chunk
# TODO: $limit should be an option
my($limit) = 5e+9;
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
    # TODO: replace below w zpaq (which requires hardlinks, non trivial)
    # command to tar this newly created chunk
    print C "(sudo tar --bzip -cvf - --files-from=filelist$chunk.txt | gpg -r $private{gpg}{user} --always-trust --encrypt -o gpgfile$chunk.gpg) 1> out$chunk.txt 2> err$chunk.txt\n";
  }

  # safe copy of line for statlist
  my($line) = $_;

  # TODO: does this always get rid of symlink targets properly?
  s/\' \-> \`(.*)\'/\'/;

  # file name, type, and size
  s/^(\d+)//;
  my($size) = $1;
  s/\'(.*?)\'//;
  my($type) = $1;
  # TODO: does this fail on some files?
  s/\`(.*)\'\s*//;
  my($filename) = $1;
  debug("FNAME: $filename");

  # type we ignore or accept?
  if ($ignore{$type}) {next;}
  unless ($accept{$type}) {warn "IGNORING UNKNOWN TYPE: $type"; next;}

  $tot+= $size;

  # NOTE: to avoid problems w/ filesizes > $limit, we add to chunk
  # first and THEN check for overage
  print A "$filename\n";
  print B $line;
}

close(A); close(B); close(C);

# TODO: check out/err files for "tar:" errors when actually running;
