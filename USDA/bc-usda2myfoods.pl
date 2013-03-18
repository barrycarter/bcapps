#!/bin/perl

=item comment

Converts the output of:

SELECT f.id,
long_desc, nt.name, n.amount FROM food f JOIN nutrition
n ON (f.id = n.food_id) JOIN nutrient nt ON (nt.id = n.nutrient_id)
WHERE nutrient_id IN (
208, 204, 606, 601, 307, 205, 291, 269, 203, 318, 262, 303, 645, 430,
306, 324, 605, 301, 401, 323
);

(in sqlite3 -line form) to INSERT statements for myfoods.db

=cut

require "/usr/local/lib/bclib.pl";
dodie("chdir('/home/barrycarter/BCGIT/USDA')");

# converts USDA field names to myfoods fieldnames
%convert = (
	    "Vitamin E (alpha-tocopherol)" => "vitamine",
	    "Vitamin D" => "vitamind",
	    "Fiber, total dietary" => "dietaryfiber",
	    "Vitamin K (phylloquinone)" => "vitamink",
	    "Vitamin C, total ascorbic acid" => "vitaminc",
	    "Caffeine" => "caffeine",
	    "Sodium, Na" => "sodium",
	    "Iron, Fe" => "iron",
	    "Total lipid (fat)" => "totalfat",
	    "Calcium, Ca" => "calcium",
	    "Fatty acids, total monounsaturated" => "monounsaturatedfat",
	    "Potassium, K" => "potassium",
	    "Protein" => "protein",
	    "Fatty acids, total saturated" => "saturatedfat",
	    "Carbohydrate, by difference" => "totalcarbohydrate",
	    "Energy" => "calories",
	    "Cholesterol" => "cholesterol",
	    "Sugars, total" => "sugars",
	    "Vitamin A, IU" => "vitamina",
	    "Fatty acids, total trans" => "transfat"
	    );

# these fields apply to all USDA data
%fixed = (
	  "file" => "http://ndb.nal.usda.gov/ndb/foods/list",
	  "url" => "http://ndb.nal.usda.gov/ndb/foods/list",
	  "weight" => "100",
	  "Manufacturer" => "USDA database",
	  "serving size" => "100g",
	  "servingsizeingrams" => 100,
	  "servingsize_prepared" => 100,
	  "comments" => "USDA units differ for vitamins + maybe others"
	  );

open(A,"bzcat usda-line-dump.bz2|");

while (<A>) {
  chomp;

  # skip empty lines
  if (/^\s*$/) {next;}

  # the dump is highly redundant so this is inefficient
  /^\s*(.*?)\s*\=\s*(.*?)$/;
  my($key,$val) = ($1,$2);

  $val=~s/[\'\"]//isg;

  if ($key eq "id") {
    # change the current id, and set the fixed fields (+ UPC special case)
    $curid = $val;
    $data[$curid]{UPC} = "USDA$val";
    for $i (keys %fixed) {
      $data[$curid]{$i} = $fixed{$i};
    }
    next;
  }

  if ($key eq "long_desc") {$data[$curid]{Name} = $val; next;}
  if ($key eq "name") {
    $curname = $val;
    next;
  }

  # only remaining case is amount
  unless ($key eq "amount") {die "BAD KEY: $key IN $_";}

  # amount (after converversion)
  my($foodname) = $convert{$curname};
  unless ($foodname) {die "NO CONVERSION FOR $curname";}
  $data[$curid]{$foodname} = $val;

}

# making data an array is inefficient (the USDA ids are sparse), but
# lets me use hashlist2sqlite

@queries = hashlist2sqlite(\@data, "foods");

debug(@queries);

print "BEGIN;\n";
print join(";\n", @queries);
print ";\n";
print "COMMIT;\n";


