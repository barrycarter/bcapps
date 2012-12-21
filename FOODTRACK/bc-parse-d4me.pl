#!/bin/perl

# Parses data from directions4me.org

require "/usr/local/lib/bclib.pl";

# these things are known to be keys
for $i ("file", "Name", "Manufacturer", "UPC") {$iskey{$i}=1;}

# sorting the mapping file has the unusual effect of semi-randomizing
# it, since the first field is a sha1sum
open(A,"/mnt/sshfs/D4M4/mapping-sorted.txt");

# print queries to a file
open(B,">/var/tmp/bcpd4m-queries.txt");

print B "BEGIN;\n";

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

#  if (++$n>1000) {
#    warn "TESTING";
#    last;
#  }

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
    $iskey{$key}=1;
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
      # I use double quote as delimiter, so cant be in cells
      $cell=~s/\"//isg;

#      $cell =~s/[^a-z]//isg;
      push(@arr, $cell);
#      debug("PUSHED: $cell");
    }

    # from the header only, remove bad characters and case-desensitize
    $arr[0]=~s/[\s\(\)\-\/\'\"]//isg;
    $arr[0] = lc($arr[0]);
    # hash for this row (assuming it has a header)
    $hash{$arr[0]} = coalesce([@arr[1..$#arr]]);
    # make note of all keys
    $iskey{$arr[0]}=1;
  }

  # only stuff that has calories (just in case other check failed)
  unless ($hash{calories}) {next;}

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

for $i (keys %iskey) {
  unless ($i) {next;}
  push(@keys,"'$i'");
}

$keys = join(", ",@keys);

open(C,">/var/tmp/bcpd4m-schema.txt");
print C << "MARK";
DROP TABLE IF EXISTS foods;
CREATE TABLE foods ($keys);
MARK
;

close(C);

system("sqlite3 /home/barrycarter/BCINFO/sites/DB/dfoods.db < /var/tmp/bcpd4m-schema.txt");
system("sqlite3 /home/barrycarter/BCINFO/sites/DB/dfoods.db < /var/tmp/bcpd4m-queries.txt");
