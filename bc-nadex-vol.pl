#!/bin/perl

# Computes implicit volatility of NADEX binary options

require "bclib.pl";

# TODO: add theta, delta, vega, etc, based on calculated volt(?)

# HACK: TODO: this only works if underlying prices change slowly: if
# there's a big change <h>(say USDJPY dropping 300 points in
# minutes)</h>, this program yields inaccurate results

# TODO: standardize USD-CAD USD/CAD USDCAD convention

# obtain hash containing inverse std normal
# TODO: this is hideously ugly, because it doesn't cache AND I need a more
# uniform way of converting mathematica output to Perl
# NOTE: I chose NOT to use nestify() here, it would've made things worse?
$invnor = read_file("data/inv-norm-as-list.txt");
# mathematica precision oddness + other cleanup
$invnor=~s/\`[\d\.]+//isg;
# NOTE: yes, I should backslash {} below, but it's cool that I don't have to
$invnor=~s/[{}]//isg;
$invnor=~s/\s+/ /isg;
# and hashify
%invnor = split(/\,\s*/, $invnor);

# Obtain NADEX quotes and FOREX quotes
%hash = nadex_quotes("USD-CAD");

# NADEX runs on Eastern time
$ENV{TZ} = "EDT5EST";

open(A,">/tmp/nadex.m");
print A "nadex={\n";

# Table header
# expdatetime, strike, bid, ask, bidvol, askvol, pricetime, underatpricetime
print "<table border>\n<tr>\n";
print "<th>Expiration</th>\n";
print "<th>Strike</th>\n";
print "<th>Bid</th>\n";
print "<th>Ask</th>\n";
print "<th>Volt<br>(Bid)</th>\n";
print "<th>Volt<br>(Ask)</th>\n";
print "<th>Exp Time<br>(hours)</th>\n";
print "<th>Pips<br>Away</th>\n";
print "<th>Last Updated</th>\n";
print "<th>Underlying<br>Price</th>\n";
print "<th>Notes</th>\n";
print "</tr>\n";

for $strike (sort keys %{$hash{USDCAD}}) {
  for $exp (sort keys %{$hash{USDCAD}{$strike}}) {
    %k = %{$hash{USDCAD}{$strike}{$exp}};
    ($bid, $ask, $updated) = ($k{bid}, $k{ask}, $k{updated});

    # obtain FOREX quote when this NADEX quote was last updated
    my($under) = forex_quote("USD/CAD", $updated);

    # logdiff + exptime (seconds)
    $logdiff = log($strike/$under);
    $exptime = $exp - $updated;

    # bid and ask represent what values of standard normal dist?
    $bidsn = $invnor{$bid/100};
    $asksn = $invnor{$ask/100};

    # normalize SD for actual expiration time
    $bidsd = $logdiff/$bidsn;
    $asksd = $logdiff/$asksn;

    # and adjust to yearly
    $bidsdy = $bidsd*sqrt(365.2425*86400/$exptime);
    $asksdy = $asksd*sqrt(365.2425*86400/$exptime);

    # round and fix sign
    $bidsdy = sprintf("%0.2f", abs($bidsdy*100));
    $asksdy = sprintf("%0.2f", abs($asksdy*100));

    # notes
    $notes="&nbsp;";

    if ($bid<=50 && $ask>=50) {
      $notes="BID/ASK crosses 50<br>volt meaningless";
    }

    # output for Mathematica
    print A "{$strike, $exp, $bid, $ask, $under, $updated},\n";

    # printing table here just to have some output; real work is above
    print "<tr>\n";
    print strftime("<td>%F<br>%H:%M:%S ET</td>\n", localtime($exp));
    print "<td>$strike</td>\n";
    print "<td>$bid</td>\n";
    print "<td>$ask</td>\n";
    print "<td>$bidsdy</td>\n";
    print "<td>$asksdy</td>\n";
    print sprintf("<td>%0.2f</td>\n", ($exp-$updated)/3600);
    print sprintf("<td>%d</td>\n", 10000*($strike-$under));
    print strftime("<td>%F<br>%H:%M:%S ET</td>\n", localtime($updated));
    print "<td>$under</td>\n";
    print "<td>$notes</td>\n";
    print "</tr>\n";

    debug("$strike/$exp/$bid/$ask/$updated/$under");
    debug("$logdiff/$exptime/$bidsn/$asksn");
    debug("BIDSD: $bidsd, ASKSK: $asksd");
    debug("FINAL: $bidsdy/$asksdy");
  }
}

print "</table>\n";
print A "}\n";
