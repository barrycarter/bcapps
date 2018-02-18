#!/bin/perl

# phash argument images and output as hex
# based on https://metacpan.org/pod/Phash::FFI

# TODO: consider renaming to bc-imagehash.pl to avoid name collision

require "/usr/local/lib/bclib.pl";
use Phash::FFI;
use Linux::UserXAttr;

for $i (@ARGV) {

  # TODO: consider tying attribute to mtime since mtime change could
  # mean whole thing has changed

  # phashing takes a while, so store it in an extended file attribute
  my($hash) = Linux::UserXAttr::getxattr($i, "dctImageHash");

  # take hash in normal case that I havent set it already + store it
  unless ($hash) {
    debug("$i: taking hash, not already known");
    $hash = Phash::FFI::dct_imagehash($i);
    Linux::UserXAttr::setxattr($i, "dctImageHash", $hash);
  }

  printf("%x $i\n", $hash);
}

