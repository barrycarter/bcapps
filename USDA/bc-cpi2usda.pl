#!/bin/perl

# Attempts to help me convert the US Consumer Price Index data
# (ftp://ftp.bls.gov/pub/time.series/ap/) to match the USDA food db
# (http://ndb.nal.usda.gov/ndb/foods/list), though Im not entirely
# convinced this is actually possible

require "/usr/local/lib/bclib.pl";

my($file) = "/home/barrycarter/BCGIT/USDA/ap.item";

for $i (split(/\n/,read_file($file))) {
  chomp($i);
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



