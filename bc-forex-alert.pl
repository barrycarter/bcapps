#!/bin/perl

# Trivial wrapper around forex_quote(), intended to run from cron
# every 1m (even though it looks back 5m)

require "/home/barrycarter/BCGIT/bclib.pl";
$now = stardate(time());

@x=forex_quote("USD/CAD",time(),"list=true");

($low, $high) = (.9837, .9900);
# ($low, $high) = (.9868, .9869);

for $i (@x) {
  %hash = ();
  while ($i=~s%<(.*?)>(.*?)</\1>%%) {
    $hash{lc($1)} = $2;
  }

  debug("HASH",unfold(%hash));
  debug("$hash{bid} - $hash{offer}");

  # theoretically possible for both to be true, but not worth testing
  if ($hash{bid} < $low) {
    $msg = "BC FOREX ALERT: USDCAD: $hash{bid} < $low ($now)";
  } elsif ($hash{offer} > $high) {
    $msg = "BC FOREX ALERT: USDCAD: $hash{offer} < $high ($now)";
  } else {
    $msg = "";
  }

  # if there is a msg, display it + kill old messages to avoid clutter
  if ($msg) {
    system("pkill -f 'BC FOREX ALERT: USDCAD'");
    system("xmessage -geometry 1024 -nearmouse '$msg' &");
    # no need to check rest
    exit();
  }
}


