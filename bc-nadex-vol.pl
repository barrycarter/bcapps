#!/bin/perl

# Computes implicit volatility of NADEX binary options

require "bclib.pl";

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

# debug(unfold(\%hash));

# debug(unfold($hash{USDCAD}));

for $strike (keys %{$hash{USDCAD}}) {
  for $exp (keys %{$hash{USDCAD}{$strike}}) {
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

#    warn("FORCE DEBUG");
    $globopts{debug}=1;
    debug("$strike/$exp/$bid/$ask/$updated/$under");
    debug("$logdiff/$exptime/$bidsn/$asksn");
    debug("BIDSD: $bidsd, ASKSK: $asksd");
    debug("FINAL: $bidsdy/$asksdy");
    $globopts{debug}=0;
  }
}
