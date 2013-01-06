#!/bin/perl

# Does pretty much what bc-track-foods.pl does with these enhancements:
#   - foods info in single file (foods.txt), better format/errorchecking
#   - uses dfoods.db, not spreadsheet
#   - records (but doesnt currently use) time I eat foods
#   - foods.txt is open source, easier to see what program does

# TODO: add option to not include 0 calorie foods and/or beverages in
# total weight (ie, beverage-like products)

# TODO: d4m uses "-5" to mean "< 5", which throws off totals; must fix this

require "/usr/local/lib/bclib.pl";

# TODO: make this less kludgey
# load the list of UPC translations for foods we dont have info for
for $i (`egrep -v '^\$|^#' /home/barrycarter/BCGIT/FOODTRACK/upctranslate.txt`) {
  unless ($i=~/^(\d+)\s+(\d+)$/) {die "BAD LINE: $i in upctranslate.txt";}
  $upctranslate{$1} = $2;
}

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
    unless ($j=~/^([\d\.]+[cug]?)\*(.*?)\@(\d{4})$/) {
      die "BAD LINE: $j";
    }

    ($quant, $food, $time) = ($1, $2, $3);
    debug("QFT: $quant $food $time");
    # translate upc if needed
    if ($upctranslate{$food}) {$food = $upctranslate{$food};}
    # must convert to UPC-A code here
    $food = upc2upc($food);
    $isupc{$food} = 1;
    # this may be nonidentical to $j because of translates above
    push(@{$foods{$date}}, "$quant*$food\@$time");
  }
}

# lookup UPC codes
for $i (keys %isupc) {
  # need to convert code since I *do* use shortcodes (nope, done above)
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
# this intentionally trumps data in dfoods.db, which has errors
@res2 = sqlite3hashlist($query,"/home/barrycarter/BCINFO/sites/DB/myfoods.db");
# Order below is important: myfoods must trump dfoods
@res = (@res2,@res);

# write file of UPCs -> products to make my life easier
open(A,">/home/barrycarter/BCGIT/FOODTRACK/upcfoods.txt");

# map UPC to nutrition data
for $i (@res) {
  # dont link UPC to info twice (harmless, but creates dupes in upcfoods.txt)
  if ($info{$i->{UPC}}) {next;}
  print A "$i->{UPC} $i->{Name} ($i->{Manufacturer})\n";
  $info{$i->{UPC}} = $i;
}

close(A);

# compare list we got to list we want
my(@gotinfo) = keys %info;
my(@wanted) = keys %isupc;
my(@missing) = minus(\@wanted,\@gotinfo);
if (@missing) {die "No info for: @missing";}

# everything find, so go through days
for $i (keys %foods) {
  for $j (@{$foods{$i}}) {
    # parse food data
    $j=~/^([\d\.]+[cug]?)\*(.*?)\@(\d{4})$/;
    # <h>Unfascinating fact: item and time are anagrams</h>
    my($quant, $item, $time) = ($1, $2, $3);
    %item = %{$info{$item}};

    debug("$quant/$item/$time");

    # TODO: just doing calories now for testing

    # convert serving size to actual servings
    if ($quant=~/^[\d\.]+$/) {
      # do nothing, but dont throw error
    } elsif ($quant=~s/^([\d\.]+)c$//) {
      # in containers
      $quant = $1*$item{'servings per container'};
    } elsif ($quant=~s/^([\d\.]+)g$//) {
      # in grams
      debug("gramming: $item{Name}");
      $quant = $1/$item{'servingsizeingrams'};
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


