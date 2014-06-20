#!/bin/perl

# I am using feh's caption feature to rapidly list characters
# appearing in each Pearls Before Swine strip; this script parses
# those caption files and outputs semantic triples to pbs-cl.txt

require "/usr/local/lib/bclib.pl";

# the conversions (capital letters = mention, but no appearance)
%full = ("p" => "[[character::Pig]]",
	 "r" => "[[character::Rat]]",
	 "g" => "[[character::Goat]]",
	 "z" => "[[character::Zebra]]",
	 "P" => "[[character::Pig]]",
	 "pastis" => "[[character::Stephan Pastis]]",
	 "max" => "[[character::Max (lion)]]",
	 "patty" => "[[character::Patty (crocodile)]]",
	 "zach" => "[[character::Zach (lion)]]",
	 "kiki" => "[[character::Kiki (lion)]]",
	 "gigi" => "[[character::Gigi (lion)]]",
	 # special case for Guard Duck to upcase "Duck"
	 "guard duck" => "[[character::Guard Duck]]"
	 );

# when using slash mode...
for $i ("pig", "rat", "zebra", "goat", "farina", "pigita", "larry", "junior",
       "snuffles", "andy") {
  $full{$i} = "[[character::".ucfirst($i)."]]";
  $full{ucfirst($i)} = "[[character::".ucfirst($i)."]]";
}

# "done" is special case for slash mode meaning "list of chars is
# complete", currently unused
$full{done} = "[[char_list_complete::1]]";

# similar for unnamed/anon
$full{anon} = "[[null::null]]";
$full{unnamed} = "[[null::null]]";
$full{other} = "[[null::null]]";

open(A,">/home/barrycarter/BCGIT/METAWIKI/pbs-cl.txt");

# where these special captions are (not in the main PBS directory!)
for $i (glob "/mnt/extdrive/GOCOMICS/pearlsbeforeswine/CHARLIST/*.txt") {
  $all = read_file($i);
  $all = trim($all);

  # if entire file is a single character, hack
  if ($full{$all}) {$all="$all/";}

#  debug("ALL: $all");

  # if I use "/" anywhere in line, I'm using that as separator
  # characters appearing in this strip
  if ($all=~/\//) {
    @data = split(/\//, $all);
    $slashmode = 1;
  } else {
    @data = split(//,$all);
    $slashmode = 0;
  }

  # convert to full form
  for $j (@data) {
    if ($full{$j}) {
      $j = $full{$j};
    } else {
      $nofullform{lc($j)} = 1;
      $j = "";
    }
  }

  # date of this strip
  $i=~/(\d{4}-\d{2}-\d{2})/ || warn("BAD FILE: $i");
  $date = $1;

  # and print
  print A join(" ",$date,@data),"\n";
}

close(A);

if (%nofullform) {
  warn("NOFULLFORM:\n", join("\n", sort keys %nofullform));
}

