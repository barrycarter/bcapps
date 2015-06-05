#!/bin/perl

# Given a SINGLE argument for bc-cityfind.pl, applies transformations
# until bc-cityfind.pl returns an answer, and then returns answer in
# bc-cityfind.pl format

require "/usr/local/lib/bclib.pl";

# <h>When the lights go down on</h>
my($city) = @ARGV;

# keep original city for printout
my($ocity) = $city;

# remove double dots (not helpful, but...)

while ($city=~s/\.\././g) {}

# even before the first attempt, we can fix these
$city=~s/cte\.divoire\.cote\.divoire/cote.divoire/g;
$city=~s/libyan\.arab\.jamahiriya/libya/g;

# TODO: maybe put these in main loop for things like
# port.st..joe.florida.united.states
$city=~s/^st\./saint./;
$city=~s/^mt\./mount./;

# the District of Columbia is small enough that we can ignore which part
if ($city=~m%district.of.columbia.united.states$%) {$city="washington.dc.usa";}


debug("GOT: $city");

# stripping dots so we can at least find a "containing" area's
# latitude/longitude

do {

  debug("TRYING: $city");
  my($out,$err,$res) = cache_command2("bc-cityfind.pl $city");

  # if we got something, return it after changing cityq
  if ($out=~s%<cityq>(.*?)</cityq>%<cityq>$ocity</cityq>\n<city_real>$1</city_real>%s) {print $out; exit;}
} while ($city=~s/^.*?\.//);


