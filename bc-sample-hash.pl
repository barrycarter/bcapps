#!/bin/perl

# Hashing very large files to compare them for equality is difficult;
# this program cheats by "randomly" (but consistently) sampling 10K of
# each 1M of the file, and hashing the result and adding size

# --srand: srand with this integer, not 20150213666

# TODO: do a random-but-consistent seed for each group of files if we
# won't be comparing one set of files to another

require "/usr/local/lib/bclib.pl";

defaults("srand=20150213666");

for $i (@ARGV) {
  # this is important; must re-seed each time
  srand($globopts{srand});

  # silently ignore dirs
  if (-d $i) {next;}

  unless (-f $i) {warn "SKIPPING: $i, no such file"; next;}

  my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($i);
  # -1 because last chunk is incomplete
  my($chunks) = floor($size/1000000)-1;
  if ($chunks<=9) {
    # use regular sha1 for under 10M?
#    debug("SKIPPING $i, < 10M");
    system("sha1sum",$i);
    next;
  }

  # where I store the sha1s for each chunk, appended together
  my($sha);

  # TODO: test for non-openability
  open(A,$i);

  # TODO: it would be more efficient to just have a bunch of random
  # numbers pre-generated
  for $j (0..$chunks) {
    my($rand) = int(rand(1000000));
    my($buf);
#    debug("RAND: $rand");
    # seek and read the 10K bytes
    seek(A, $rand, SEEK_SET);
    read(A, $buf, 10000);
    $sha .= sha1_hex($buf);
  }

  close(A);

  # sha the appended sha strings
  my($shafin) = sha1_hex($sha);
  # and print
  print "$shafin.$size $i\n";
}
