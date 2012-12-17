#!/bin/perl

# parses foodfacts.com data

require "/usr/local/lib/bclib.pl";

# these fields can be null (not all manufacturers provide them)
%nullok = list2hash("Vitamin A", "Vitamin C", "Calcium", "Iron");

# these fields should not be stripped of 'g/mg/%'
%nostrip = list2hash("Serving Size");

# this file contains output of:
# fgrep -liR 'upc code:' . | tee fileswithupc.txt
@upc = split(/\n/, read_file("/mnt/sshfs/FF/fileswithupc.txt"));

for $i (@upc) {

  # convert to absolute path
  $i=~s%^\.%/mnt/sshfs/FF%;
#  debug("FILE: $i");

  # read file
  $data = read_file($i);

  # was being too clever, doing these individually now
  %item = ();
  $item{file} = $i;

  # these are similar (key: value)
  for $j ("Serving Size", "Servings Per Container") {
    $data=~s%$j:\s*(.*?)\s*</span>%%;
    $item{$j} = $1;
  }

  # also similar (key value)
  for $j ("Calories", "Total Calories", "Saturated Fat", "Trans Fat",
	 "Dietary Fiber", "Sugars") {
    $data=~s%>$j\s*(.*?)\s*<%%;
    $item{$j} = $1;
  }

  # <strong>key:?</strong>value
  for $j ("Total Fat", "Cholesterol", "Sodium", "Potassium",
	  "Total Carbohydrate", "Protein", "Manufactured by", "Brand",
	 "UPC Code", "Found In") {
    $data=~s%<strong>$j:?\s*</strong>\s*(.*?)\s*</%%s;
#    $data=~s%<strong>$j:\s*</strong>(.*?)<%%s;
    $item{$j} = $1;
  }

  # <strong>key </strong></span><span class="nutri-center"> val</span>
  for $j ("Vitamin A", "Vitamin C", "Calcium", "Iron") {
    $data=~s%<strong>$j\s*</strong></span><span.*?>\s*(.*?)\s*</span>%%;
    $item{$j} = $1;
  }

  # name/title (2nd test slightly more reliable?)
#  $data=~s%<title>(.*?)</title>%%s;
  $data=~s%<div class="product-title">\s*<h2>(.*?)</h2>%%s;
  $item{Title} = $1;

  # check that fields are nonnull
  for $j (keys %item) {
    if ($nullok{$j}) {next;}
    unless (length($item{$j})) {
      warn "$i,$j,$item{$j}";
    }
  }

  # strip trailing g, mg, or % from all fields
  # remove HTML tags (should be none at this point) + quotes
  # TODO: can I do this in the nonnull check?
  for $j (keys %item) {
    # even serving size must be stripped of quotation marks
    $item{$j}=~s/\"//isg;
    if ($nostrip{$j}) {next;}
    $item{$j}=~s/\s*(mg|g|%)$//;
    $item{$j}=~s/<.*?>//isg;
  }

#  for $j (sort keys %item) {
#    debug("$j: $item{$j}");
#  }

#  if (++$count > 1000) {warn "TESTING"; last;}

  push(@items, {%item});
}

@queries = hashlist2sqlite(\@items, "foods");

print "BEGIN;\n";
print join(";\n",@queries),";\n";
print "COMMIT;\n";

# TODO: make some columns INT and FLOAT for better sorting (default is text)
# TODO: current version is highly incomplete, fix!

=item schema

CREATE TABLE foods ('Brand', 'Calcium', 'Calories', 'Cholesterol',
'Dietary Fiber', 'Found In', 'Iron', 'Manufactured by', 'Potassium',
'Protein', 'Saturated Fat', 'Serving Size', 'Servings Per Container',
'Sodium', 'Sugars', 'Title', 'Total Calories', 'Total Carbohydrate',
'Total Fat', 'Trans Fat', 'UPC Code', 'Vitamin A', 'Vitamin C',
'file');

=cut
