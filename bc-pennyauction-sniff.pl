#!/bin/perl

# Sniffs the pennyauctionsite.com bids and alerts when an item has
# only 2 bidders left (which is a good time to bid on it)

require "bclib.pl";

# TODO: get these numbers directly, don't hardcode
# Ugly possibility: include ALL numbers 1-999 below (penny handles
# this, but yuck)
$ids = "285,245,320,292,304";

for (;;) {
  # obtain info
  # TODO: subroutineize this
  # TODO: why does cache_command need age=-100 hack?
  ($out,$err,$res) = cache_command("curl -L 'http://pennyauctionsite.com/down/info.php?ids=$ids'", "age=-100");

  # parse $out
  while ($out=~s/(\#.*?)\#/\#/) {
    $item = $1;
    ($num, $start, $bidtime, $bidder, $price) = split(/\|/, $item);
    # keep track of each item/bidder combos last bidtime
    # NOTE: should I use my own clock here "just in case"?
    debug("ITEM: $item");
    $lastbid{$num}{$bidder} = $bidtime;
  }

  debug(unfold(%lastbid));

}

=item sample_output

2011-09-12 17:46:44#245|2011-09-12 12:00:00|2011-09-12 17:46:59|JUMARANDTARA|12.92#285|2011-09-11 23:49:00|2011-09-12 17:46:53|l.gladden|40.63#292|2011-09-12 16:30:00|2011-09-12 17:47:00|DMCMILLIAN|2.91#304|2011-09-12 17:00:00|2011-09-12 17:46:48|loyaswife|1.64#320|2011-09-12 16:00:00|2011-09-12 17:44:25|ted.ball|4.13

=cut
