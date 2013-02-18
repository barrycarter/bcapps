#!/bin/perl

# creates a psuedorandom name using Census distributions; not super
# useful, especially since firstnames and lastnames are not
# independent; nice way to generate "random" names without getting
# stuck on a single name <h>(aka the "Ryan Stiles" problem)</h>

require "/usr/local/lib/bclib.pl";
chdir("/home/barrycarter/BCGIT/419/");

# random numbers
$first = rand()*100;
# <h>Using Perl keywords as variable, wrong or just stupid?</h>
$last = rand()*100;

debug($first,$last);

# currently doing females only <h>("doing females", hee hee)</h>
@first = split(/\n/,read_file("dist.female.first"));
@last = split(/\n/,read_file("dist.all.last"));

# debug(@first,@last);

# TODO: files do not go to 100th %ile, must adjust
for $i (0..$#first) {
  my($name,$pct,$cum,$rank) = split(/\s+/, $first[$i]);
  debug("NAME: $name");
  debug("COMP: $cum / $first");
  if ($cum > $first) {$firstname = $name; last;}
}

for $i (0..$#last) {
  my($name,$pct,$cum,$rank) = split(/\s+/, $last[$i]);
  debug("NAME: $name");
  debug("COMP: $cum / $last");
  if ($cum > $last) {$lastname = $name; last;}
}

print "$firstname $lastname\n";


