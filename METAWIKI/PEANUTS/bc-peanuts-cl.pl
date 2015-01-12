#!/bin/perl

# I am using feh's caption feature to rapidly list characters
# appearing in each Peanuts; this script parses
# those caption files and outputs semantic triples to peanuts-cl.txt

# NOTE: there are known errors in my NOTES files, need to fix

require "/usr/local/lib/bclib.pl";

# short form to long form
%full = ("cb" => "Charlie Brown",
	 "sn" => "Snoopy",
	 "lu" => "Lucy",
	 "li" => "Linus",
	 "sa" => "Sally",
	 "wo" => "Woodstock",
	 "ma" => "Marcy",
	 "sc" => "Schroeder",
	 "pep" => "Peppermint Patty",
	 "pp" => "Peppermint Patty",
	 "vi" => "Violet",
	 "spike" => "Spike",
	 "pa" => "Patty",
	 "re" => "Rerun",
	 "sh" => "Shermy",
	 "" => ""
);

# output file
open(A,">$bclib{githome}/METAWIKI/PEANUTS/PEANUTS-cl.txt");

for $i (glob "/mnt/extdrive/GOCOMICS/PEANUTS/20150106/IMAGES/NOTES/*.txt") {

  # figure out the date
  $i=~/(\d{4}\-\d{2}\-\d{2})/;
  my($date) = $1;

  $all = read_file($i);
  @chars = split(/\//, $all);

  my($type);
  for $j (@chars) {
    if ($j=~s/\(m\)//) {$type = "mentioned";} else {$type = "character";}

    # TODO: changing the loop variable is possibly a bad idea
    unless ($full{$j}) {
      warn "CANT HANDLE: $date: $j";
      $j = "";
      next;
    }

    $j = "[[$type\:\:$full{$j}]]";
  }

  print A "$date ",join(" ",@chars),"\n";
}

close(A);


