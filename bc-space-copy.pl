#!/bin/perl

# copy files from /home/barrycarter/LIB2KINDLE to kindle (currently at
# /mnt/usbext2/), but exclude files already there; however, target
# files may have spaces in name while source do not

# sense I've written this before

require "/usr/local/lib/bclib.pl";

@kindle = glob("/mnt/usbext2/documents/*.mobi");
@hd = glob("/home/barrycarter/LIB2KINDLE/*.mobi");

# remove dir paths and spaces/dollarsigns
for $i (@kindle,@hd) {
  $i=~s%^.*/%%isg;
  $i=~s/[\s\$]/_/isg;
}

debug("KINDLE",@kindle);
debug("HD",@hd);


@copy = minus([@hd], [@kindle]);

debug(@copy);


