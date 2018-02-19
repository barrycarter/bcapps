#!/bin/perl

# phash argument images and output as hex
# based on https://metacpan.org/pod/Phash::FFI

# TODO: consider renaming to bc-imagehash.pl to avoid name collision

require "/usr/local/lib/bclib.pl";
use Phash::FFI;

for $i (@ARGV) {

  # TODO: consider tying attribute to mtime since mtime change could
  # mean whole thing has changed

  # do i have phash already
  my($out, $err, $res) = cache_command2("attr -qg dctImageHash $i");
  $hash = $out;
  debug("ALPHA: $hash");

  unless ($hash) {
    debug("$i: taking hash, not already known");
    $hash = Phash::FFI::dct_imagehash($i);
    ($out, $err, $res) = cache_command2("attr -s dctImageHash -V $hash $i");
  }

  printf("%0.16x $i\n", $hash);
}

