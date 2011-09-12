#!/bin/perl

# Sniffs the pennyauctionsite.com [hereafter, simply "penny"] bids and
# alerts when an item has only 2 bidders left (which is a good time to
# bid on it)

require "bclib.pl";

# TODO: get these numbers directly, don't hardcode
# Ugly possibility: include ALL numbers 1-999 below (penny handles
# this, but yuck)
$ids = "285,245,320,292,304";

# TODO: fix cache_command so I don't have to do this
$globopts{nocache} = 1;

for (;;) {
  # obtain info
  # TODO: subroutineize this
  ($out,$err,$res) = cache_command("curl -L 'http://pennyauctionsite.com/down/info.php?ids=$ids'");

  # parse $out
#  debug("OUTPRE: $out");
  while ($out=~s/(\#.+?)(\#|$)/\#/) {
#    debug("OUTNOW: $out");
    $item = $1;
    ($num, $start, $bidtime, $bidder, $price) = split(/\|/, $item);
    # keep track of each item/bidder combos last bidtime
    # NOTE: should I use my own clock here "just in case"?
#    debug("ITEM: $item");
    $lastbid{$num}{$bidder} = str2time("$bidtime UTC");
  }

  # penny time
  $out=~s/\#$//isg;
  $cur = str2time("$out UTC");
  debug("$out -> $cur");

  # determine bidders in last 2m (TODO: 5m?)
  for $i (sort keys %lastbid) {
    @bidders = ();
    for $j (sort keys %{$lastbid{$i}}) {

      # kill bids over 120s
      if ($cur-$lastbid{$i}{$j} > 120) {
	delete $lastbid{$i}{$j};
	next;
      }

      push(@bidders,$j);
    }

    print "$i: ".join(", ",@bidders)."\n";
  }

#  debug(unfold(%lastbid));
  sleep(5);

}

=item sample_output

2011-09-12 17:46:44#245|2011-09-12 12:00:00|2011-09-12 17:46:59|JUMARANDTARA|12.92#285|2011-09-11 23:49:00|2011-09-12 17:46:53|l.gladden|40.63#292|2011-09-12 16:30:00|2011-09-12 17:47:00|DMCMILLIAN|2.91#304|2011-09-12 17:00:00|2011-09-12 17:46:48|loyaswife|1.64#320|2011-09-12 16:00:00|2011-09-12 17:44:25|ted.ball|4.13

=cut
