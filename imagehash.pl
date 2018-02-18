#!/bin/perl

# almost literal copy of https://metacpan.org/pod/Phash::FFI

use Phash::FFI;
my($hash) = Phash::FFI::dct_imagehash($ARGV[0]);
printf "%064b\t%s\n", $hash, $ARGV[0];
