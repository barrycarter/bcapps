#!/bin/perl

# Attempts to help me convert the US Consumer Price Index data
# (ftp://ftp.bls.gov/pub/time.series/ap/) to match the USDA food db
# (http://ndb.nal.usda.gov/ndb/foods/list), though Im not entirely
# convinced this is actually possible

require "/usr/local/lib/bclib.pl";

# obtain current prices for items (we wont necessarily use all of these)
# TODO: currently hardcoded for Sep 2012, change this
# 0000 = all cities location code
open(A,"grep 2012 /home/barrycarter/BCGIT/USDA/ap.data.3.Food | grep -i m09| grep 0000|");

while (<A>) {
  # strip season and location code (location always 0000)
  s/^ap.0000//isg;
  # we know year/month are 2012/m09, so don't really need them
  ($code, $x, $x, $price) = split(/\s+/,$_);
  $price{$code} = $price;
}

for $i (split(/\n/,read_file("/home/barrycarter/BCGIT/USDA/food.items.txt"))) {
  # ignore comments
  if ($i=~/^\#/) {next;}


  # if this line contains only cpi number, warn but skip
  if ($i=~/^(\S+)\t/) {
    debug("BAD LINE: $i");
    next;
  }

  # weight is usally per lb, but figure out if not
  # this gives number to divide by to get 100g
  if ($i=~/per lb/) {
    $div = 4.536;
  } elsif ($i=~/egg/i && $i=~/large/i && $i=~/doz/i) {
    # dozen large eggs weigh 24oz (http://www.ams.usda.gov/AMSv1.0/getfile?dDocName=STELDEV3004376)
    $div = 6.804;
  } elsif ($i=~/(\d+) oz\./) {
    # TODO: orange juice concentrate is given in volume oz, so this isn't 100% inaccurate
    $div = $1*.2835;
  } elsif ($i=~/milk/i && $i=~/whole/i) {
    # gallon milk = 8.6 pounds (http://www.ers.usda.gov/data-products/price-spreads-from-farm-to-consumer/documentation.aspx)
    $div = 39;
  } else {
    debug("BAD WEIGHT: $i");
  }

  # split into usda items, cpi index number
  $i=~/^(.*?)\s+(.*?)\s+/;
  my($usda, $cpi) = ($1,$2);

  # and the query
  # TODO: editing the existing USDA table is ugly, but easier than creating
  # a new one, especially given that we have repeats
  $query = "INSERT INTO prices (food_id, price) VALUES ($usda, $price{$cpi}/$div)";

  debug("QUERY: $query");
  debug("I: $i");
  debug("USDA: $usda, CPI: $cpi, PRICE: $price{$cpi}");
  next;

  chomp($i);
  debug("I: $i"); next;
  $i=~s/\s*$//isg;
  $i=~/^(.*?)\t(.*)$/||warn("Bad line: $i");
  my($num,$food) = ($1,$2);

  # will try to match part of food before comma
  $sfood=$food;
  $sfood=~s/\,.*//;

  # query (this is redundant, since many sfood's are identical)
  $query = "SELECT id||' '||long_desc AS usda FROM food WHERE long_desc LIKE '$sfood%'";
  debug($query);

  @res = sqlite3hashlist($query,"/home/barrycarter/BCINFO/sites/DB/usda.db");

  print "\n\nFOOD: $num $food [$sfood]\n\n";

  for $j (@res) {
    %hash = %{$j};
    print "$hash{usda}\n";
  }

}



