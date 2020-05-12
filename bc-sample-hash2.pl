#!/bin/perl

# Hashing very large files to compare them for equality is difficult;
# this program cheats by "randomly" (but consistently) sampling 10K of
# each 1M of the file, and hashing the result and adding size

# --srand: srand with this integer, not 20200512074010
# --chunks: number of chunks to read (default 1000)

# TODO: do a random-but-consistent seed for each group of files if we
# won't be comparing one set of files to another

# TODO: version 2 uses a fixed number of test points, not 1 for every
# million bytes

require "/usr/local/lib/bclib.pl";

defaults("srand=20200512074010&chunks=1000");

for $i (@ARGV) {
  # this is important; must re-seed each time
  srand($globopts{srand});

  # silently ignore dirs
  if (-d $i) {next;}

  unless (-f $i) {warn "SKIPPING: $i, no such file"; next;}

  # TODO: test for non-openability
  open(A,$i)||die("Can't open $i, giving up");

  my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($i);

  my($sha);

  # 10k points with 10k bytes each (overage permitted)

  for $j (1..$globopts{chunks}) {

    my($rand) = round(($j+rand())*$size/10000);
    my($buf);

    debug("J: $j, RAND: $rand");
    # seek and read the 10K bytes
    seek(A, $rand, SEEK_SET);
    read(A, $buf, 10000);
    $sha .= sha1_hex($buf);
  }

  close(A);

  my($shafin) = sha1_hex($sha);
  # and print
  print "$shafin.$size $i\n";

}
