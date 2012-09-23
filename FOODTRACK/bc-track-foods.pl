#!/bin/perl

# attempts to track my eating habits

# Examples of SHORT: lines
# SHORT: 3*SUBTURKHAMSALAD, 9*749601012066, 1*76150232486, DONE
# SHORT: 4*SUBTURKHAMSALAD, 8*749601012066, 3*KFCGRILLEDDRUMSTICK, DONE
# SHORT: 7*KFCGRILLEDDRUMSTICK, 1*41196911169, 3*637480025324, 4*749601012066, DONE
# SHORT: 6*CRUNCHYFRESCOTACO, 3*637480025324, 1*41196911169, 1*SCHWAN741, DONE
# SHORT: 1*37600199919, 2*SUBSPICITALSALAD, 6*44700009000, DONE
# SHORT: 2*SUBSPICITALSALAD, 7*260165002323, 1*43000958254, DONE

require "/usr/local/lib/bclib.pl";

# list of fields it makes sense to total
# TODO: order this list
@totalfields = ("Saturated Fat", "Calcium", "Vitamin A", "Total Fat", "Cholestrol", "Iron", "Trans Fat", "Total Carbohydrates", "Sugars", "Vitamin C", "Protein", "Fiber", "Sodium", "Calories");

# load the hash of known foods
@knownfoods=gnumeric2array("/home/barrycarter/BCGIT/FOODTRACK/foods.gnumeric");
($x, $hashref) = arraywheaders2hashlist(\@knownfoods, "UPC");
%hash = %{$hashref};

# debug(%hash);

# bc-SUPERFILE has a lot of very dull information, including my eating habits
open(A,"/home/barrycarter/bc-SUPERFILE")||die("Can't open, $!");

# skip to the right section
while (<A>) {
  if (/<section name="fooddiary">/i) {last;}
}

while (<A>) {
  # end section
  if (m%</section>%) {last;}
  # the only things Im interested in are "SHORT:" lines (a
  # machine-readable summary of what I ate) + date
  if (/^(\d+\s+[A-Z][a-z]{2}\s+\d+)$/) {
    $date = $1;
    next;
  }

  # unless SHORT: move on
  unless (/^SHORT:\s*(.*?)\s*$/) {next;}

  # clear vars from last time
  %total = ();
  $done = 0;

  # count number of days
  $days++;

  @foods = split(/\s*,\s*/, $1);
  debug("FOODS",@foods);

  # if done for day, note so
  # TODO: don't average for days that are not done, throws off results
  if ($foods[-1] eq "DONE") {$done=1; pop(@foods);}

  # parse foods
  for $i (@foods) {

    if ($i=~/^([\d\.]+)\*(.*?)$/) {
      ($quant, $item) = ($1, $2);
    } else {
      ($quant, $item) = (1,$2);
    }

    debug("ITEM: $item");
    # kill leading 0s
    # TODO: fix this in spreadsheet somehow
    $item=~s/^0+//isg;

    # if no such food, warn
    unless ($hash{$item}) {
      warn "NO SUCH FOOD: $item";
      next;
    }

    %itemhash = %{$hash{$item}};

    debug("IH: $itemhash{'Personal Serving'}");

    # if I have a setting for personal servings, use it
    if ($itemhash{'Personal Serving'}) {$quant*=$itemhash{'Personal Serving'}};

    debug("$quant of $item");

    for $j (@totalfields) {
      $total{$j} += $quant*$itemhash{$j};
      # across multiple days
      $grandtotal{$j} += $quant*$itemhash{$j};
    }
  }

  # totals for day
  print "\nDATE: $date\n";
  for $j (@totalfields) {
    print "$j: $total{$j}\n";
  }
}

# grand totals
print "\nGRAND TOTALS: ($days days)\n";
for $j (@totalfields) {
  $avg = $grandtotal{$j}/$days;
  printf("%s: %0.2f\n", $j,$avg);
}

