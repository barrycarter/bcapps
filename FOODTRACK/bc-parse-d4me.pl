#!/bin/perl

# Parses data from directions4me.org

require "/usr/local/lib/bclib.pl";

# it turns out directionsforme.org tracks over 2000 nutrients, and
# SQLite3 is default limited to 2000 columns; I can increase this, but
# instead will focus on columns I really need/want

#<h>Im not sure I want 'file' as a column, but I can always use
#SQLite3s DROP COLUMN feature later (try to figure out why this is
#funny<G>)</h>

%validkeys = list2hash("file", "Name", "Manufacturer", "UPC", "url",
"caffeine", "calcium", "cholesterol", "dietaryfiber", "iron",
"monounsaturatedfat", "potassium", "protein", "saturatedfat", "serving size", "servings per container", "sodium", "sugars",
"totalcarbohydrate", "totalfat", "transfat", "vitamina", "vitaminc",
"vitamind", "vitamine", "vitamink", "weight", "servingsize_prepared", "servingsizeingrams", "calories");

# these things are known to be keys
for $i ("file", "Name", "Manufacturer", "UPC") {$iskey{$i}=1;}

# sorting the mapping file has the unusual effect of semi-randomizing
# it, since the first field is a sha1sum
open(A,"/mnt/sshfs/D4M4/maptest-sorted.txt");
warn "TESTING";

# print queries to a file
open(B,">/var/tmp/bcpd4m-queries.txt");

print B "BEGIN;\n";

while (<A>) {
  ++$count;

  # get both filename and target URL
  /^(.*?)\s+(.*?)$/;
  ($file,$url) = ($1,$2);

  # correct to full path
  $file=~s%^%/mnt/sshfs/D4M4/%;

  # mapping.txt contains mappings for files that don't exist (yet); skip those
  unless (-f $file) {
    debug("NOEXIST: $_");
    next;
  }

  $all = read_file($file);

  # ignore files sans calories (case-sensitive) It turns out there are
  # foods/beverages with 0 calories that dont even have a Calories
  # listing, so this check is wrong

#  unless ($all=~/Calories/) {
#    debug("NOTFOOD: $_");
#    next;
#  }

  my(%hash) = ();
  $hash{url} = $url;

  # note filename for debugging
  $hash{file} = $file;

  debug("FILENAME: $file");

  # product name
  if ($all=~s%<title>(.*?)</title>%%) {
    $hash{Name} = $1;

    # just an info page, no product
    if ($hash{Name} eq "Directions for Me") {
      debug("NO ITEM: $file");
      next;
    }

    $hash{Name}=~s/\s\-\s*Directions for me//i;
  } else {
    debug("NO ITEM: $file");
    next;
  }

#  if (++$n>1000) {
#    warn "TESTING";
#    last;
#  }

#  debug("N: $n/$count");

  # now, the longer name
  if ($all=~s%<h2>$hash{Name}</h2>\s*<p>(.*?)</p>%%) {
    $hash{Name} .= ": $1";
  } else {
    warn "NO EXTRA INFO IN $file, suspect!";
  }

  debug("NAME: $hash{Name}");

  # special case for data delimited using <strong>
  while ($all=~s%<strong>(.*?):?</strong>(.*?)<%%is) {
    ($key,$val) = (lc($1),$2);
#    $key=~s/[^a-z]//isg;
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
    $row = $1;

    @arr = ();
    while ($row=~s%<td.*?>(.*?)</td>%%is) {
      # cleanup cell + push to row-specific array
      $cell = $1;
      debug("CELL PRE: $cell");
      # remove g/mcg/mg at end only (also % and extra space)
#      debug("CELL: $cell");
      $cell=trim($cell);
      $cell=~s/\s*m?c?g$//;
      $cell=~s/\s*\%$//;
      debug("CELL POST: $cell");
      push(@arr, $cell);
    }

    # from the header only, remove bad characters and case-desensitize
    $arr[0]=~s/[\s\(\)\-\/\'\"]//isg;
    $arr[0] = lc($arr[0]);

    # is this info we want? (if not, record that we are ignoring it)
    unless ($validkeys{$arr[0]}) {
      $ignored{$arr[0]}=1;
      next;
    }

    # hash for this row (assuming it has a header)
    $hash{$arr[0]} = coalesce([@arr[1..$#arr]]);
    # make note of all keys
  }

  # only stuff that has calories (just in case other check failed)
#  unless ($hash{calories}) {next;}

  # I use double quote as delimiter, so cant be in cells (any hash vals at all)
  for $i (keys %hash) {
    $hash{$i}=~s/\"//isg;
  }

  # silly to wrap single hash in list, but I didnt want to write new function
  $l[0] = \%hash;
#  debug("0: $l[0]");

  # this gets large, so print on a row by row basis
  @query = hashlist2sqlite(\@l,"foods");

  print B "$query[0];\n";

  # debug(hashlist2sqlite(\@hashes, "foods"));
  # push(@hashes, \%hash);

}

print B "COMMIT;\n";
close(B);

debug("IGNORED",sort keys %ignored);

for $i (keys %validkeys) {
  unless ($i) {next;}
  # because of SQLite3s "non"-typing, this should work fine
  push(@keys,"'$i' REAL");
}

$keys = join(", ",@keys);

open(C,">/var/tmp/bcpd4m-schema.txt");
print C << "MARK";
DROP TABLE IF EXISTS foods;
CREATE TABLE foods ($keys);
MARK
;

close(C);

die "TESTING, run sqlite3 commands manually";

system("sqlite3 /home/barrycarter/BCINFO/sites/DB/dfoodstwo.db < /var/tmp/bcpd4m-schema.txt");
system("sqlite3 /home/barrycarter/BCINFO/sites/DB/dfoodstwo.db < /var/tmp/bcpd4m-queries.txt");
