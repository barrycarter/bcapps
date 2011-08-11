#!/bin/perl

# compute fair value of box option using Mathematica (wrapper script)

push(@INC, "/usr/local/lib");
require "bclib.pl";

# HTML header
print "Content-type: text/html\n\n";

# read the query string and remove unwanted chars
$query = $ENV{QUERY_STRING};
$query=~s/[^a-z0-9\.\=\&]//isg;
%query = str2hash($query);

# vars: p0 = price of underlying, v = annual volatility of underlying,
# p1 = box low price, p2 = box high price, t1 = box start time, t2 =
# box end time

# laziness here
($p0, $v, $p1, $p2, $t1, $t2) =
 ($query{p0}, $query{v}, $query{p1}, $query{p2}, $query{t1}, $query{t2});

print "QUERY IS: $query, p0: $p0, $t1 to $t2\n";

chdir(tmpdir());

# calculate for nearby volatilities and prices
$str = << "MARK";

Table[N[{p0,v, boxvalue[p0, v, $p1, $p2, $t1, $t2]}], 
 {p0, $p0-10/10000, $p0+10/10000, 1/10000},
 {v, $v-2/100, $v+2/100, 1/100}
] // AccountingForm

MARK
;

write_file($str, "calc");

# do the calculation and cleanup the results
$res = join("\n",`math -initfile /sites/TEST/box-option-value.m < calc`);
$res=~s/\s*>\s*/ /isg;

while ($res=~s/{(.*?), (.*?), (.*?)}//) {
  # price, volatility, and probability of hitting box
  ($pri, $v, $pro) = ($1,$2,$3);

  # cleanup
  $pri=~s/[{}]//isg;
  $v=~s/[{}]//isg;
  $pro=~s/[{}]//isg;

  # hashify
  $prob{$pri}{$v} = $pro;
  $validvol{$v} = 1;
}

# TODO: printing things straight out is really not great
print "<table border><tr><th>*</th>\n";

# column headers (volatilities)
for $i (sort keys %validvol) {
  print "<th>$i</th>\n";
}

print "</tr>";

# row "headers" (prices)
for $i (sort keys %prob) {
  print "<tr><th>$i</th>\n";
  for $j (sort keys %{$prob{$i}}) {
    # print probability, and values calculated from it
    $prob = $prob{$i}{$j};

    # probability very low or very high (avoids division by 0)
    if ($prob < 1e-6) {
      ($hitval, $missval, $ohitval, $omissval) = ("~0%");
    } elsif ($prob > 1-(1e-6)) {
      ($hitval, $missval, $ohitval, $omissval) = ("~100%");
    } else {

      # the Mathematica script only calculates probability; below, I
      # compute value of a hit and miss option of $1000
      $hitval = 1000/$prob;
      $missval = 1000/(1-$prob);

      # TODO: assuming OANDA pays "half" the true value (of sorts), but
      # this assumption appears to be completely false
      $ohitval = ($hitval-1000)*.5+1000;
      $omissval = ($missval-1000)*.5+1000;
    }

    printf("<td>%0.2f%%<br>%0.0f/%0.0f<br>%0.0f/%0.0f</td>\n",
	   $prob*100, $hitval, $missval, $ohitval, $omissval);
  }
  print "</tr>\n";
}

print "</table>\n";

# stuff below not working
exit(0);

for $i (@res) {
  if ($i=~/^Out\[(\d+)\]=\s*(.*?)$/) {
    $arr[$1] = $2;
    ($hit[$1], $miss[$1]) = (1000/$2, 1000/(1-$2));
  }
}

$arr[0] = "value";

@delta = ("delta", $arr[2]-$arr[1], $hit[2]-$hit[1], $miss[2]-$miss[1]);
@vega = ("vega", $arr[3]-$arr[1], $hit[3]-$hit[1], $miss[3]-$miss[1]);
@theta = ("theta", $arr[4]-$arr[1], $hit[4]-$hit[1], $miss[4]-$miss[1]);

# TODO: hideous redundant code below

print "<table border>\n";
print "<tr><th>Item</th><th>Chance</th><th>Hit</th><th>Miss</th></tr>\n";

print sprintf("<tr><td>Option</td><td>%0.4f%%</td><td>%0.2f</td><td>%0.2f</td></tr>\n", $arr[1]*100, $hit[1], $miss[1]);

print sprintf("<tr><td>Delta (per pip)</td><td>%+0.4f%%</td><td>%+0.2f</td><td>%+0.2f</td></tr>\n", ($arr[2]-$arr[1])*100, $hit[2]-$hit[1], $miss[2]-$miss[1]);

print sprintf("<tr><td>Theta (per minute)</td><td>%+0.4f%%</td><td>%+0.2f</td><td>%+0.2f</td></tr>\n", ($arr[3]-$arr[1])*100, $hit[3]-$hit[1], $miss[3]-$miss[1]);

print sprintf("<tr><td>Vega (per 0.01)</td><td>%+0.4f%%</td><td>%+0.2f</td><td>%+0.2f</td></tr>\n", ($arr[4]-$arr[1])*100, $hit[4]-$hit[1], $miss[4]-$miss[1]);

print "</table>\n";

# compute fair value of $1000 hit and miss options, given probability

sub fairhitmiss {
  my($p) = @_;
  return [1000/p, 1000/(1-$p)];
}
