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
@totalfields = ("Calories", "Total Fat", "Total Carbohydrates", "Sugars", "Saturated Fat", "Calcium", "Vitamin A", "Cholestrol", "Iron", "Trans Fat", "Vitamin C", "Protein", "Fiber", "Sodium");

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
#  debug("FOODS",@foods);

  # if done for day, note so
  # TODO: don't average for days that are not done, throws off results
  if ($foods[-1] eq "DONE") {$done=1; pop(@foods);}

  # parse foods
  for $i (@foods) {

    if ($i=~/^([\d\.]+)\*(.*?)$/) {
      ($quant, $item) = ($1, $2);
    } else {
      # item remains as is
      ($quant, $item) = (1, $i);
    }

#    debug("ITEM: $item");
    # kill leading 0s
    # TODO: fix this in spreadsheet somehow
    $item=~s/^0+//isg;

    # if no such food, warn
    unless ($hash{$item}) {
      warn "NO SUCH FOOD: $item";
      next;
    }

    %itemhash = %{$hash{$item}};

#    debug("IH: $itemhash{'Personal Serving'}");

    # if I have a setting for personal servings, use it
    if ($itemhash{'Personal Serving'}) {$quant*=$itemhash{'Personal Serving'}};

#    debug("$quant of $item");

    for $j (@totalfields) {
      $total{$j} += $quant*$itemhash{$j};
      # across multiple days
      $grandtotal{$j} += $quant*$itemhash{$j};
    }
  }

  # totals for day
  print "\nDATE: $date\n";
  for $j (@totalfields) {
    # stardate format (to store total just in case we need it later)
    $stardate = stardate(str2time($date),"localtime=1");
    $stardate=~s/\..*$//isg;
    $totals{$stardate}{$j} = $total{$j};
    print "$j: $total{$j}\n";
  }
}

# averages
print "\nAVERAGE: ($days days)\n";
for $j (@totalfields) {
  $avg{$j} = $grandtotal{$j}/$days;
  printf("%s: %0.2f\n", $j,$avg{$j});
}

# calories I "earn" per hour is average calories divided by 16 hours
# (since I usually dont eat right up to bedtime, this has the effect
# of bringing down the average slightly if I follow it)
$calsperhr = $avg{Calories}/16;

# Calorie banking: every hour I'm awake, I allow myself $calsperhr calories.

# <h>While most of my programs are designed to help just me and
# clutter github, this one may actually harm me, since I'm pretty sure
# calorie banking is a bad idea... I don't even get an ATM card!</h>

# today's date (store HMS for later)
$today = stardate("","localtime=1");
$today=~s/\.(.*)$//isg;
$hms = $1;

# TODO: maybe add --wake= for cases when TODAY file is inaccurate

# find the first instance of 'wake' in "today's" file (which is
# usually a fairly good indication of when I woke)
$wake = `grep wake /home/barrycarter/TODAY/$today.txt`;

# extract HMS
$wake=~s/\s+.*$//isg;

# convert to seconds since midnight, same for $hms
$wake=~s/^(..)(..)(..)$/$1*3600+$2*60+$3/e;
$hms=~s/^(..)(..)(..)$/$1*3600+$2*60+$3/e;

# compute calories earned
$cals = $calsperhr*($hms-$wake)/3600;

# already eaten
$eaten = $totals{$today}{Calories};

# must eat 1200 cals min by 2030
$timeto830 = 60*(20*60+30)-$hms;
$reqperhr = 3600*(1200-$eaten)/$timeto830;
debug("PER HOUR: $reqperhr");

# remaining
$remain = $cals-$eaten;

printf("\nHours Awake: %0.2f\nCalories Earned: %d\nCalories Eaten: %d\nCalories Remaining: %d\n\n", ($hms-$wake)/3600, $cals, $eaten, $remain);

printf("Hours to 2030: %0.2f\nCalories Required: %d\nCalories Eaten: %d\nCalories remaining (total): %d\nCalories Remaining (per hour): %d\n\n", $timeto830/3600, 1200, $eaten, 1200-$eaten, 3600*(1200-$eaten)/$timeto830);

# string for bc-bg.pl
$bgstring = sprintf("kcal: %d/%d/%d (remain/earned/eaten)",$remain,$cals,$eaten);

write_file_new($bgstring, "/home/barrycarter/ERR/cal.inf");

# TODO: my days don't always end at midnight, compensate

