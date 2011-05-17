#!/bin/perl

# Computes implicit volatility of NADEX binary options

require "bclib.pl";

# HACK: TODO: this only works if underlying prices change slowly: if
# there's a big change <h>(say USDJPY dropping 300 points in
# minutes)</h>, this program yields inaccurate results

# Obtain NADEX quotes and FOREX quotes
%hash = nadex_quotes("USDCAD");

# debug(unfold(\%hash));

# debug(unfold($hash{USDCAD}));

for $strike (keys %{$hash{USDCAD}}) {
  for $exp (keys %{$hash{USDCAD}{$strike}}) {
    %k = %{$hash{USDCAD}{$strike}{$exp}};
    ($bid, $ask, $updated) = ($k{bid}, $k{ask}, $k{updated});
    debug("$strike/$exp/$bid/$ask/$updated/$usdcad");
  }
}
