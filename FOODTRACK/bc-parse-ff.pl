#!/bin/perl

# parses foodfacts.com data

require "/usr/local/lib/bclib.pl";

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
	 "UPC Code:") {
    $data=~s%<strong>$j:?\s*</strong>\s*(.*?)\s*</%%s;
#    $data=~s%<strong>$j:\s*</strong>(.*?)<%%s;
    $item{$j} = $1;
  }

  # <strong>key </strong></span><span class="nutri-center"> val</span>
  for $j ("Vitamin A", "Vitamin C", "Calcium", "Iron") {
    $data=~s%<strong>$j\s*</strong></span><span.*?>\s*(.*?)\s*</span>%%;
    $item{$j} = $1;
  }

  # UPC (or other) code
#  $data=~s%<strong>UPC Code:</strong>\s*(.*?)\s*</li>%%s;
#  $item{"UPC Code"} = $1;

  # name/title
  $data=~s%<title>(.*?)</title>%%s;
  $item{Title} = $1;



  # TODO: check that all fields are non-null
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
