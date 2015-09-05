#!/bin/perl

# The final final step of the quest to find conjunctions: this takes
# the annmsepsdump dump files and converts them to a MySQL database

require "/usr/local/lib/bclib.pl";

use DateTime;

$dt = DateTime->from_epoch( epoch => -31556952000. );

debug($dt->jd());


# debug(get_timet_from_julian(2.4666864981041644e6));





die "TESTING";

# for $i (glob "/home/barrycarter/SPICE/KERNELS/annmsepsdump*.txt") {

warn "TESTING WITH CURRENT FILE";

for $i (glob "/home/barrycarter/SPICE/KERNELS/annmsepsdump-2451536-2816816.txt") {
  my($all) = read_file($i);

  while ($all=~s/annminsep\[\{(.*?)\}\]\s*=\s*\{(\{.*?\})\}//s) {

    my($planets,$data) = ($1,$2);
    my(@planets) = split(/\,\s*/s,$planets);

    while ($data=~s/\{(.*?)\}//s) {
      my($jd, $sep, $sun, $star, $ssep) = split(/\,\s*/s,$1);
      $jd=~s/\*\^/e/;
      debug("$planets/$jd/$sep/$sun/$star/$ssep");
    }
  }

  debug("LEFTOVER: $all");

  die "TESTING";
}
