#!/bin/perl

# copy files from /home/barrycarter/LIB2KINDLE to kindle (currently at
# /mnt/usbext2/), but exclude files already there; however, target
# files may have spaces in name while source do not

# sense I've written this before

require "/usr/local/lib/bclib.pl";

@kindle = glob("/mnt/usbext2/documents/*.mobi");
@hd = glob("/home/barrycarter/LIB2KINDLE/*.mobi");

for $i (@kindle,@hd) {
  $j = $i;
  # remove dir path and normalize
  $i=~s%.*?/%%isg;
  $i=~s/[^0-9a-z]//isg;
  $map{$i} = $j;
}

# debug("KINDLE",@kindle);
# debug("HD",@hd);


@copy = minus([@hd], [@kindle]);

for $i (@copy) {
  print "cp $map{$i} /mnt/usbext2/documents/\n";
}
