#!/bin/perl

# Parses data from directions4me.org

require "/usr/local/lib/bclib.pl";

# this is an ugly way to do this
print << "MARK";
DROP TABLE IF EXISTS foods;
CREATE TABLE foods ('Calories', 'Calories from Fat', 'Cholesterol', 'Is or Contains Eg', 'Is or Contains Flavor', 'Is or Contains Kosher', 'Is or Contains Milk', 'Is or Contains Organic', 'Is or Contains Peanut', 'Is or Contains Soy', 'Is or Contains Tree Nut', 'Is or Contains Wheat', 'Manufacturer', 'Name', 'Protein', 'Saturated Fat', 'ServingSize-InGrams', 'Servingsize', 'Servingspercontainer', 'Sodium', 'Sugars', 'Total Carbohydrate', 'Total Fat', 'UPC', 'Weight', 'file', 'Calcium', 'Dietary Fiber', 'Iron', 'Chromium (as Chromium GTF Polynicotinate)', 'Folate (as Folate Acid)', 'Gluten', 'Vitamin A', 'Is or Contains Gluten Free', 'Iodine', 'Niacin', 'Milk', ' Is or Contains Low Fat', 'Phosphorus', 'Riboflavin', 'Soy', 'Is or Contains Low Fat', 'Potassium', 'Thiamin', 'Wheat', 'Vitamin D');
BEGIN;
MARK
;

# sorting the mapping file has the unusual effect of semi-randomizing
# it, since the first field is a sha1sum
open(A,"/mnt/sshfs/D4M4/mapping-sorted.txt");

while (<A>) {
  ++$count;

  # only need filename not target URL
  s/\s+.*$//isg;

  # correct to full path
  s%^%/mnt/sshfs/D4M4/%;

  # mapping.txt contains mappings for files that don't exist (yet); skip those
  unless (-f $_) {
#    debug("NOEXIST: $_");
    next;
  }

  $all = read_file($_);

  # ignore files sans calories (case-sensitive)
  unless ($all=~/Calories/) {
#    debug("NOTFOOD: $_");
    next;
  }

  if (++$n>1000) {
    warn "TESITNG";
    last;
  }

  debug("N: $n/$count");

  my(%hash) = ();

  # note filename for debugging
  $hash{file} = $_;

  # product name
  $all=~s%<title>(.*?)</title>%%;
  $hash{Name} = $1;
  $hash{Name}=~s/\s*\-\s*Directions for me//i;

  # special case for data delimited using <strong>
  while ($all=~s%<strong>(.*?):?</strong>(.*?)<%%is) {
    ($key,$val) = ($1,$2);
    # ignore empties and numericals
    if ($key=~/^\d*$/) {next;}
    $key=~s/[^a-z]//isg;
    $hash{$key} = trim($val);
  }

  # special cases for manufacturer
  $all=~s%<h3>Manufacturer</h3>\s*(.*?)<%%;
  $hash{Manufacturer} = $1;

  # and UPC
  $all=~s%<h3>UPC</h3>\s*<p>(.*?)</p>%%;
  $hash{UPC} = $1;

#  debug("ALL: $all");

  # go through table rows and cells
  while ($all=~s%<tr.*?>(.*?)</tr>%%is) {
    $row = $1;

    # ignore empty (not working, may contain empty <td>s
#    if ($row=~/^\s*$/s) {next;}

#    debug("ROW: $row");
    @arr = ();
    while ($row=~s%<td.*?>(.*?)</td>%%is) {
      # cleanup cell + push to row-specific array
      $cell = $1;
      # remove g/mcg/mg at end only (also % and extra space)
#      debug("CELL: $cell");
      $cell=trim($cell);
      $cell=~s/\s*m?c?g$//;
      $cell=~s/\s*\%$//;

#      $cell =~s/[^a-z]//isg;
      push(@arr, $cell);
#      debug("PUSHED: $cell");
    }

    # hash for this row (assuming it has a header)
    $hash{$arr[0]} = coalesce([@arr[1..$#arr]]);
  }

  # only stuff that has calories (just in case other check failed)
  unless ($hash{Calories}) {next;}

  # silly to wrap single hash in list, but I didnt want to write new function
  $l[0] = \%hash;
#  debug("0: $l[0]");

  # this gets large, so print on a row by row basis
  @query = hashlist2sqlite(\@l,"foods");

  print "$query[0];\n";

  # debug(hashlist2sqlite(\@hashes, "foods"));
  # push(@hashes, \%hash);


}

print "COMMIT;\n";
