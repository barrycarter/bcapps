#!/bin/perl

# Parses HTML downloads from ING DIRECT. Although ING DIRECT (now part
# of Capital One) offers an OFX download, this download clips merchant
# names AND ING DIRECT has conceded the OFX downloads aren't always
# accurate/complete. Thus, the HTML downloads are more useful to me.

# This is another program that's probably useful just to me

push(@INC,"/usr/local/lib");
require "bclib.pl";
chdir(tmpdir());
($all,) = cmdfile();

# really should use XML parser, but too lazy
# divs we want start with class= "s4" or "s15"; class="s32" is meta-separator
while ($all=~s%<div class=\"s[14].*?>(.*?)</div>%%is) {
  $line = $1;

  # ignore until end of headers (month starts with 0 or 1)
  if ($line=~/^[01]/) {$OK=1;}
  unless ($OK) {next;}

  push(@lines, $line);
}

open(A,">querys.txt");
print A "BEGIN;\n";

# suck them down 5 fields at a time
while (($date, $desc, $with, $dep, $bal) = @lines[$n..$n+5]) {
  if ($n > $#lines) {last;}
  $n+=5;

  # amount is either $with or $dep; figure out which, assign sign, cleanup
  if ($with eq "&nbsp;") {
    $amount = "$dep";
  } else {
    $amount = "-$with";
  }

  $amount=~s/,//;

#  debug("WITH/DEP: $with/$dep");
#  $amount = (-1*$with)||$dep;
#  $amount=~s/,//isg;
#  debug("AMOUNT: $amount");
#  $amount=~s/\.00$//;

  # cleanup balance
  $bal=~s/,//isg;

  # date to MySQL form
  $date=~s%^(\d{2})/(\d{2})/(\d{4})$%% || warn("BAD DATE: $date");
  ($yr,$mo,$da) = ($3,$1,$2);

  # below for backwards compat
  $mo=~s/^0//;
  $da=~s/^0//;

  # I sometimes have 2+ transactions with the same day/merchant/amount
  # (FOREX, gotta love it). Since I don't have a FITID here, making up
  # a hash that includes the balance (the one thing that changes
  # between the two otherwise identical transactions; an older version
  # of this program calculated the hash incorrectly, but I still need
  # that

  $oldhash = sha1_hex("INGDIRECT$amount$yr$mo$da$desc");
  $newhash = sha1_hex("INGDIRECT$amount$yr$mo$da$desc$bal");

  debug("HASHING: INGDIRECT$amount$yr$mo$da$desc$bal -> $newhash");

  debug($amount);

  # query for MySQL
  print A "INSERT IGNORE INTO bankstatements
 (bank, amount, date, unique_id, description, balance, oldhash) VALUES
 ('INGDIRECT', $amount, '$yr-$mo-$da', '$newhash', '$desc', '$bal',
  '$oldhash');\n";
}

print A "COMMIT;\n";

close(A);

# purely so I can look at it after prog ends
system("cp querys.txt /tmp");

print "mysql test < /tmp/querys.txt;: if desired\n";
