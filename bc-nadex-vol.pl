#!/bin/perl

# Computes implicit volatility of NADEX binary options. Options:
#  -under=x: assume underlying price is x, do not call forex_quote

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
# TODO: this may break when we stop daylight time(?)
$ENV{TZ} = "EST5EDT";

open(A,">/tmp/nadex.m");
print A "nadex={\n";

# Table header
# expdatetime, strike, bid, ask, bidvol, askvol, pricetime, underatpricetime

$str = << "MARK";

I know this table looks horrible. Please contact me if you know how to
fix it. Do not rely on this information. I update this table
"manually", there are no automated upates. Does not include intraday
options. Void where prohibited.

<table border><tr>
<th>Expiration</th>
<th>Strike</th>
<th>Bid</th>
<th>Ask</th>
<th>Volt<br>(Bid)</th>
<th>Volt<br>(Ask)</th>
<th>Exp Time<br>(hours)</th>
<th>Pips<br>Away</th>
<th>Last Updated</th>
<th>Underlying<br>Price</th>
<th>Notes</th>
</tr>

MARK
;

for $strike (sort keys %{$hash{USDCAD}}) {
  for $exp (sort keys %{$hash{USDCAD}{$strike}}) {
    %k = %{$hash{USDCAD}{$strike}{$exp}};
    ($bid, $ask, $updated) = ($k{bid}, $k{ask}, $k{updated});
    debug("UPDATED: $updated");

    # obtain FOREX quote when this NADEX quote was last updated
    my($under);
    if ($globopts{under}) {
      $under = $globopts{under}
    } else {
      $under = forex_quote("USD/CAD", $updated);
    }

    # logdiff + exptime (seconds)
    debug("$strike / $under");
    $logdiff = log($strike/$under);
    $exptime = $exp - $updated;

    debug("BID: $bid, ASK: $ask");

    # bid and ask represent what values of standard normal dist?
    $bidsn = $invnor{$bid/100};
    $asksn = $invnor{$ask/100};

    # TODO: fix this (.50 implies meaningless volatility, but should
    # note that, not avoid it)
    if ($bidsn == 0 || $asksn == 0) {next;}

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

    # compute (bid) volatility using new function I created
    $newvol = bin_volt($bid, $strike, ($exp-$updated)/86400/365.2425, $under);
    debug("NEWVOL: $newvol");

    # output for Mathematica (doesn't really need all of these, but...)
    print A "{$strike, $exp, $bid, $ask, $under, $updated},\n";

    # printing table here just to have some output; real work is above
    $str.= "<tr>\n";
    $str.= strftime("<td>%F<br>%H:%M:%S ET</td>\n", localtime($exp));
    $str.= "<td>$strike</td>\n";
    $str.= "<td>$bid</td>\n";
    $str.= "<td>$ask</td>\n";
    $str.= "<td>$bidsdy</td>\n";
    $str.= "<td>$asksdy</td>\n";
    $str.= sprintf("<td>%0.2f</td>\n", ($exp-$updated)/3600);
    $str.= sprintf("<td>%d</td>\n", 10000*($strike-$under));
    $str.= strftime("<td>%F<br>%H:%M:%S ET</td>\n", localtime($updated));
    $str.= "<td>$under</td>\n";
    $str.= "<td>$notes</td>\n";
    $str.= "</tr>\n";

    debug("$strike/$exp/$bid/$ask/$updated/$under");
    debug("$logdiff/$exptime/$bidsn/$asksn");
    debug("BIDSD: $bidsd, ASKSK: $asksd");
    debug("FINAL: $bidsdy/$asksdy");
  }
}

$str.="</table>\n";

# Make current time part of subject
$subject= strftime("NADEX Implied Volatility(s) (as of %F %H:%M:%S ET)", localtime(time()));

# info about my blog
# TODO: put this somewhere where any prog can get it, but not in
# bclib.pl, since other people don't want it

$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);
$author = "barrycarter";
$wp_blog = "wordpress.barrycarter.info";

# update on blog
post_to_wp($str, "action=wp.editPage&site=$wp_blog&author=$author&password=$pw&postid=9410&wp_slug=nadex&live=1&subject=$subject");

print A "}\n";
