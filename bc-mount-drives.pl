#!/bin/perl

# another script only I can use (sort of), this remounts my drives
# using blkid, after I've had to reset the USB bus (which unmounts
# everything implicitly)

require "/usr/local/lib/bclib.pl";

# id to mountpoint, and device to id
my(%id2mp,%dev2id);

# read the blkids.txt file (private) of my drives
for $i (split(/\n/,read_file("$bclib{home}/blkids.txt"))) {
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}
  $i=~/^(.*?)\s+(.*)$/||die("BAD LINE: $i");
  $id2mp{$1}=$2;
}

my($out,$err,$res) = cache_command2("sudo blkid");

for $i (split(/\n/,$out)) {
  $i=~m%^(/dev/.*?):.*?UUID=\"(.*?)\"%||warn("BAD LINE: $i");
  $dev2id{$1}=$2;
}

# now the drives actually on the system

for $i (glob("/dev/sd* /dev/mapper/*")) {
  # drive sda (and its partitions) are main hard drive, so not interesting
  if ($i=~m%/sda%) {next;}

  # TODO: push below is fairly ugly, could do better
  my($id) = $dev2id{$i};
  unless ($id) {
    # TODO: this is broken, need to do partition stuff
    debug("NO ID, IGNORING: $i");
    push(@nomount,$i);
    next;
  }

  # and now id to mount point
  my($mp) = $id2mp{$id};
  unless ($mp) {push(@nomount,$i);next;}

  my($cmd) = "sudo mount $i $mp";
  # being chicken and just printing commands for now
  # TODO: background these, no need to do sequentially
  print "$cmd&\n";

  # this lets me check "leftovers" at end
  delete $dev2id{$i};
  delete $id2mp{$id};

  # TODO: check for already mounted, but really shouldn't be using
  # this program if some are mounted

  debug("$i -> $id -> $mp");
}

debug(%dev2id);

# TODO: this program works as much as I need it to, but is not
# complete: I need to check that all drives have their partitions or
# themselves mounted and there are no other "leftovers" from this
# process
