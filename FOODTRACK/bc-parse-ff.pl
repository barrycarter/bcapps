#!/bin/perl

# parses foodfacts.com data

require "/usr/local/lib/bclib.pl";

# these fields can be null (not all manufacturers provide them)
%nullok = list2hash("Vitamin A", "Vitamin C", "Calcium", "Iron");

# this file contains output of:
# fgrep -liR 'upc code:' . | tee fileswithupc.txt
@upc = split(/\n/, read_file("/mnt/sshfs/FF/fileswithupc.txt"));

for $i (@upc) {

  # convert to absolute path
  $i=~s%^\.%/mnt/sshfs/FF%;
  debug("FILE: $i");

  # read file
  $data = read_file($i);

  # was being too clever, doing these individually now
  %item = ();

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
	 "UPC Code:", "Found In") {
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


  next;

  # TODO: check that numeric fields are numeric, 'gram' fields end in 'g'

#  $data=~s%<span class="nutri-left"><b>Total Calories (\d+)</b>%%;
#  $item{totalcalories} = $1;

  # TODO: check calories*servings = total calories (to make sure parsing good)


  for $j (sort keys %item) {
    debug("$j: $item{$j}");
  }

  next;

  # much of info is in form below
  @info = ();
  while ($data=~s%<li class="colspan2-nutri.*?">(.*?)</li>%%s) {
    $item = $1;
    $item=~s/\s+/ /isg;

    # TODO: below is purely for debugging, I actually need the tags
    $item=~s/<.*?>//isg;
    push(@info,$item);
  }

  debug("INFO",@info);
}
