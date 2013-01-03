#!/bin/perl

# Does pretty much what bc-track-foods.pl does with these enhancements:
#   - foods info in single file (foods.txt), better format/errorchecking
#   - uses dfoods.db, not spreadsheet
#   - records (but doesnt currently use) time I eat foods
#   - foods.txt is open source, easier to see what program does

# TODO: add option to not include 0 calorie foods and/or beverages in
# total weight (ie, beverage-like products)

require "/usr/local/lib/bclib.pl";

for $i (split(/\n/,read_file("/home/barrycarter/BCGIT/FOODTRACK/foods.txt"))) {
  # ignore comments and blank lines
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}
  # ignore text-based lines like "2135 1 container cotto salami"
  if ($i=~/^\d{4}\s+/) {next;}
  # record date
  if ($i=~/^DATE: (\d{8})$/) {$date = $1; next;}
  # if anything other than SHORT: remains, complain
  unless ($i=~s/^SHORT: //) {die "BAD LINE: $i";}

  # split into foods
  @foods = split(/\,\s+/, $i);

  # record foods for day (as list) + get "UPC codes" to look up
  for $j (@foods) {
    # TODO: may loosen restriction that all foods be in this format
    unless ($j=~/^([\d\.]+[cu]?)\*(.*?)\@(\d{4})$/) {
      die "BAD LINE: $j";
    }

    ($quant, $food, $time) = ($1, $2, $3);
    $isupc{$food} = 1;
    push(@{$foods{$date}}, $j);
  }
}

# lookup UPC codes
for $i (keys %isupc) {
  # TODO: dont need to convert here because I use pure UPCs?
  #  my($code) = upc2upc($i);
  #  $upce{$code} = $i;
  push(@upcs, "'$i'");
}

# TODO: dfoods.db "-1" means "<1", need to worry about this
$upcs = join(", ",@upcs);
$query = "SELECT * FROM foods WHERE UPC IN ($upcs)";

# DBs at dfoods.db.94y.info and myfoods.db.94y.info
# results and index via UPC
@res = sqlite3hashlist($query,"/home/barrycarter/BCINFO/sites/DB/dfoods.db");
# db where I keep my own list of foods (not in dfoods.db)
@res2 = sqlite3hashlist($query,"/home/barrycarter/BCINFO/sites/DB/myfoods.db");
# 
@res = (@res,@res2);

# map UPC to nutrition data
for $i (@res) {$info{$i->{UPC}} = $i;}

# compare list we got to list we want
my(@gotinfo) = keys %info;
my(@wanted) = keys %isupc;
my(@missing) = minus(\@wanted,\@gotinfo);
if (@missing) {die "No info for: @missing";}

# everything find, so go through days
for $i (keys %foods) {
  for $j (@{$foods{$i}}) {
    # parse food data
    $j=~/^([\d\.]+[cu]?)\*(.*?)\@(\d{4})$/;
    # <h>Unfascinating fact: item and time are anagrams</h>
    my($quant, $item, $time) = ($1, $2, $3);
    %item = %{$info{$item}};

    debug("$quant/$item/$time");

    # TODO: just doing calories now for testing

    # convert serving size to actual servings
    if ($quant=~/^[\d\.]+$/) {
      # do nothing, but dont throw error
    } elsif ($quant=~s/^([\d\.]+)c$//) {
      $quant = $1*$item{'servings per container'};
    } else {
      die("QUANTITY: $quant NOT UNDERSTOOD: $j");
    }

    # note this probably doesnt make sense for all fields
    for $k (keys %item) {
      debug("ADDING $i, $j, $k, $item{Name}, $quant * $item{$k}");
      $total{$i}{$k} += $quant*$item{$k};
    }
  }
}

debug("TOTAL");
debug(unfold(%total));


