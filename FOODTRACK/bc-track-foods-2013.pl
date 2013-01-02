#!/bin/perl

# Does pretty much what bc-track-foods.pl does with these enhancements:
#   - foods info in single file (foods.txt), better format/errorchecking
#   - uses dfoods.db, not spreadsheet
#   - records (but doesnt currently use) time I eat foods
#   - foods.txt is open source, easier to see what program does

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
    unless ($j=~/^(\d+[cu]?)\*(.*?)\@(\d{4})$/) {
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

# results and index via UPC
@res = sqlite3hashlist($query, "/home/barrycarter/BCINFO/sites/DB/dfoods.db");

for $i (@res) {$info{$i->{UPC}} = $i;}

# compare list we got to list we want
my(@gotinfo) = keys %info;
my(@wanted) = keys %isupc;

my(@missing) = minus(\@wanted,\@gotinfo);

if (@missing) {
  die "No info for: @missing";
}


