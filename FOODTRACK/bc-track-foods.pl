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

# one off for coke one, er coke zero
print hashlist2sqlite([{d4me2db("049000042566")}],"foods"),";";

die "TESTING";

# list of fields it makes sense to total
# TODO: order this list
@totalfields = ("Calories", "Total Fat(g)", "Total Carbohydrates(g)", "Sugars(g)", "Saturated Fat(g)", "Calcium(%DV)", "Vitamin A(%DV)", "Cholestrol(mg)", "Iron(%DV)", "Trans Fat", "Vitamin C(%DV)", "Protein(g)", "Fiber(g)", "Sodium(mg)");

# load the hash of known foods
@knownfoods=gnumeric2array("/home/barrycarter/BCGIT/FOODTRACK/foods.gnumeric");
($x, $hashref) = arraywheaders2hashlist(\@knownfoods, "UPC");
%hash = %{$hashref};

debug(%hash);

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

  # this keeps dates in order
  push(@dates,$date);

  @foods = split(/\s*,\s*/, $1);

  # if done for day, note so (feature never used, dropped)

  # parse foods
  for $i (@foods) {

    # negative foods allowed to subtract items off other items (eg, subway sandwich with no/less bread)
    if ($i=~/^(\-?[\d\.]+)\*(.*?)$/) {
      ($quant, $item) = ($1, $2);
    } else {
      # item remains as is
      ($quant, $item) = (1, $i);
    }

    # store what I ate on what day, look up later
    push(@{$foods{$date}}, "$quant*$item");

    # note that this is an item (so we can look it up)
    $isitem{$item} = 1;

=item commentout

    # kill leading 0s
    # TODO: fix this in spreadsheet somehow
    $item=~s/^0+//isg;

    %itemhash = %{$hash{$item}};

    # this is intentionally done for my personal serving count
    $totalquant{$item} += $quant;

    # if I have a setting for personal servings, use it
    if ($itemhash{'Personal Serving'}) {$quant*=$itemhash{'Personal Serving'}};

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

=cut

}}

close(A);

for $i (keys %isitem) {
  my($code) = upc2upc($i);
  $upce{$code} = $i;
  push(@upcs, "'$code'");
}

# TODO: dfoods.db "-1" means "<1", need to worry about this

$upcs = join(", ",@upcs);
$query = "SELECT * FROM foods WHERE UPC IN ($upcs)";

# note that dfoods does use %DV for vitamins

# alternate query using spreadsheet headers (ie, backwords)
$query = << "MARK";
SELECT
 UPC,
 calories AS "Calories",
 totalfat AS "Total Fat(g)",
 totalcarbohydrate AS "Total Carbohydrates(g)",
 sugars AS "Sugars(g)",
 saturatedfat AS "Saturated Fat(g)",
 calcium AS "Calcium(%DV)",
 vitamina AS "Vitamin A(%DV)",
 cholesterol AS "Cholestrol(mg)",
 iron AS "Iron(%DV)",
 transfat AS "Trans Fat",
 vitaminc AS "Vitamin C(%DV)",
 protein AS "Protein(g)",
 dietaryfiber AS "Fiber(g)",
 sodium AS "Sodium(mg)",
 'fromdb' AS source
FROM foods WHERE UPC in ($upcs)
MARK
;

debug("QUERY: $query");

=item schema

CREATE TABLE foods ('cholesterol', 'dietaryfiber', 'sodium', 'file', 'sugars', 'totalcarbohydrate', 'servings per container', 'vitamina', 'caffeine', 'url', 'weight', 'Manufacturer', 'iron', 'monounsaturatedfat', 'serving size', 'vitamink', 'potassium', 'vitamind', 'calories', 'transfat', 'saturatedfat', 'protein', 'calcium', 'vitaminc', 'UPC', 'vitamine', 'servingsizeingrams', 'Name', 'totalfat', 'servingsize_prepared');

8*044700010907: no Calories information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Total Fat(g) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Total Carbohydrates(g) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Sugars(g) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Saturated Fat(g) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Calcium(%DV) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Vitamin A(%DV) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Cholestrol(mg) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Iron(%DV) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Trans Fat information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Vitamin C(%DV) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Protein(g) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Fiber(g) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.
8*044700010907: no Sodium(mg) information, bad entry? at /home/user/BCGIT/FOODTRACK//bc-track-foods.pl line 202.


=cut


@res = sqlite3hashlist($query, "/home/barrycarter/BCINFO/sites/DB/dfoods.db");

debug("RES",unfold(@res),"/RES");

# link the UPC to the hash
for $i (@res) {$info{$upce{$i->{UPC}}} = $i;}

debug("FOODS",%foods);

# this is a repeat of what I do earlier w the spreadsheet, except I
# now use the db and already have foods for each day <h>so it's not a
# repeat of what I did earlier</h>

# TODO: allow measurements in grams, containers, etc.

for $i (@dates) {
  debug("DATE: $i");

  # clear vars from last time
  %total = ();
  $done = 0;

  # count number of days
  $days++;

  @foods = @{$foods{$i}};

  debug("FOODS($i):",@foods);

  # parse foods for day
  for $k (@foods) {

    # negative foods allowed to subtract items off other items (eg, subway sandwich with no/less bread)
    if ($k=~/^(\-?[\d\.]+)\*(.*?)$/) {
      ($quant, $item) = ($1, $2);
    } else {
      # item remains as is
      ($quant, $item) = (1, $k);
    }

    # cant trim $item, may need it for db
    $item2=$item;
    $item2=~s/^0+//isg;

    # first check spreadsheet, then db, then give up
    # <h>TO NOT DO: use coalesce here</h>
    if ($hash{$item2}) {
      %itemhash = %{$hash{$item2}};
      # restore value of $item
      $item = $item2;
    } elsif ($info{$item}) {
      %itemhash = %{$info{$item}};
    } else {
      warn "NO SUCH ITEM: $item";
      $ERR_FLAG = "NO SUCH ITEM: $item";
      next;
    }

    debug("ITEMHASH($item)",unfold(%itemhash));

    # this is intentionally done before my personal serving count
    $totalquant{$item} += $quant;

    # if I have a setting for personal servings, use it
    if ($itemhash{'Personal Serving'}) {$quant*=$itemhash{'Personal Serving'}};

    for $j (@totalfields) {

    # debugging only
    unless (length($itemhash{$j})) {
      warn "$k: no $j information, bad entry?";
    }



      $total{$j} += $quant*$itemhash{$j};
      # across multiple days
      $grandtotal{$j} += $quant*$itemhash{$j};
    }
  }

  # totals for day
  print "\nDATE: $i\n";
  for $j (@totalfields) {
    # stardate format (to store total just in case we need it later)
    $stardate = stardate(str2time($date),"localtime=1");
    $stardate=~s/\..*$//isg;
    $totals{$stardate}{$j} = $total{$j};
    print "$j: $total{$j}\n";
  }
}

die "TESTING";

for $i (keys %isitem) {
  my($code) = upc2upc($i);
  $upce{$code} = $i;
  push(@upcs, "'$code'");
}

debug("INFO",unfold(%info));

die "TESTING";

# debugging only, what do we find?
for $i (@res) {
  push(@found, "'$i->{UPC}'");
}

debug("FOUND",@found);

@notfound = minus(\@upcs, \@found);

for $i (sort @notfound) {
  $i=~s/\'//isg;
  $upce = $upce{$i};
  debug("NOTFOUND: $i -> $hash{$upce}{Name}, $hash{$upce}{Company}, $upce");
}

debug("NOTFOUND",@notfound);

for $i (@notfound) {
  # this is a oneshot
  %hash = d4me2db($i);
  unless (%hash) {next;}
  debug("GRABBED: $i, yayme!");
  push(@hashlist, {d4me2db($i)});
}

debug("HASHLIST1",@hashlist);
debug("HASHLIST2",hashlist2sqlite(\@hashlist, "foods"));

die "TESTING";

debug("ISITEM",%isitem,"/ISITEM");

# averages
print "\nAVERAGE: ($days days)\n";
for $j (@totalfields) {
  $avg{$j} = $grandtotal{$j}/$days;
  printf("%s (avg): %0.2f\n", $j,$avg{$j});
}

# calories I "earn" per hour is average calories divided by 16 hours
# (since I usually dont eat right up to bedtime, this has the effect
# of bringing down the average slightly if I follow it)
$calsperhr = $avg{Calories}/16;

# Changing this to 1200 cals / 16 hours
$calsperhr = 1200/16;

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
$wake = `egrep -i 'wake|woke' /home/barrycarter/TODAY/$today.txt`;

# error if none
unless ($wake) {
  $ERR_FLAG .= "ERR: No wake time (bctf)";
}

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

# probably printing out too much information, but heres some more

for $i (sort {$totalquant{$a} <=> $totalquant{$b}} keys %totalquant) {
  print "$i: $totalquant{$i}\n";
}

# string for bc-bg.pl
$bgstring = sprintf("kcal: %d/%d/%d (remain/earned/eaten)",$remain,$cals,$eaten);

write_file_new($bgstring, "/home/barrycarter/ERR/cal.inf");

write_file_new($ERR_FLAG, "/home/barrycarter/ERR/cal.err");

# TODO: my days don't always end at midnight, compensate

# TODO: add this subroutine to bclib.pl when working

=item d4me2db($upc)

Looks up $upc on directionsforme.org, and returns query to insert it
into dfoods.db.94y.info

=cut

sub d4me2db {
  my($upc) = @_;

  # strip quotes
  $upc=~s/[\'\"]//isg;

  unless (length($upc) == 12) {
    warn "BAD UPC: $upc";
    return;
  }

  my($url)="http://www.directionsforme.org/index.php/directions/results/$upc";
  my($all,$err,$res) = cache_command("curl -L '$url'", "age=86400");

  # this is basically bc-parsed4me.pl in subroutine form
  # ignore files sans calories (case-sensitive)
  # actually, coke zero + others HAVE no calories so this is wrong
#  unless ($all=~/Calories/) {
#    warn "NOT FOOD: $upc [$all]";
#    return;
#  }

  my(%hash) = ();
  $hash{url} = $url;

  # note filename for debugging (since no filename, note subroutine)
  $hash{file} = "d4me2db($upc)";

  # product name
  $all=~s%<title>(.*?)</title>%%;
  $hash{Name} = $1;
  $hash{Name}=~s/\s*\-\s*Directions for me//i;

  # special case for data delimited using <strong>
  while ($all=~s%<strong>(.*?):?</strong>(.*?)<%%is) {
    ($key,$val) = (lc($1),$2);
    # ignore empties and numericals
    if ($key=~/^\d*$/) {next;}
    unless ($validkeys{$key}) {
      $ignored{$key} = 1;
      next;
    }
    $hash{$key} = trim($val);
  }

  # special cases for manufacturer
  $all=~s%<h3>Manufacturer</h3>\s*(.*?)<%%;
  $hash{Manufacturer} = $1;

  # and UPC
  $all=~s%<h3>UPC</h3>\s*<p>(.*?)</p>%%;
  $hash{UPC} = $1;

  # go through table rows and cells
  while ($all=~s%<tr.*?>(.*?)</tr>%%is) {
    my($row) = $1;
    @arr = ();
    while ($row=~s%<td.*?>(.*?)</td>%%is) {
      # cleanup cell + push to row-specific array
      my($cell) = $1;
      # remove g/mcg/mg at end only (also % and extra space)
      $cell=trim($cell);
      $cell=~s/\s*m?c?g$//;
      $cell=~s/\s*\%$//;
      # I use double quote as delimiter, so cant be in cells
      $cell=~s/\"//isg;
      push(@arr, $cell);
    }

    # from the header only, remove bad characters and case-desensitize
    $arr[0]=~s/[\s\(\)\-\/\'\"]//isg;
    $arr[0] = lc($arr[0]);

    # ignore info we dont want
    unless ($d4mekeys{$arr[0]}) {next;}

    # hash for this row (assuming it has a header)
    $hash{$arr[0]} = coalesce([@arr[1..$#arr]]);
  }

  return %hash;
}

=item compute_upc_check_digit($upc)

Given an 11-digit UPC-A code (not a UPC-E code), compute the check
digit. Useful for computing UPC-E check digits after expansion.

http://en.wikipedia.org/wiki/Universal_Product_Code#Check_digits

=cut

sub compute_upc_check_digit {
  my($upc) = @_;
  my(@arr) = split(//,$upc);
  # we want arr to start with 1 to match instructions
  unshift(@arr,"");
  my($tot);

  # NOTE: Yes, I couldve written a for loop here
  for $i (1,3,5,7,9,11) {$tot += 3*$arr[$i];}
  for $i (2,4,6,8,10) {$tot += $arr[$i];}

  # <h>It vaguely bothers me this works; it bothers me more that I used it</h>
  return (10-($tot%10))%10;
}

