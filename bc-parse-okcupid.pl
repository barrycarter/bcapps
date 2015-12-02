#!/bin/perl

# Given a list of files containing okcupid profiles, output data for
# those profiles

require "/usr/local/lib/bclib.pl";

# list of info values that mean "this is not a user"
my(%bad) = list2hash("Bookmarks | OkCupid", "OkCupid | Careers", 
		     "OkCupid | About Us", "OkTrends",
		     "Free Online Dating | OkCupid", "Matches | OkCupid",
		     "Messages | OkCupid", ");

my(@fields) = ("name", "age", "location", "height", "ethnicity", "orientation",
	       "bodytype", "lastonline", "drinking", "drugs", "offspring",
	       "pets", "religion", "sign", "speaks", "status");

print join("|",@fields),"\n";

for $i (@ARGV) {
  my($all) = read_file($i);

  # apostrophe correction
  $all=~s/\xe2\x80\x99/\'/g;

  my(%hash) = ();

  # name age and location
  $all=~s%<title>\s*(.*?)\s*</title>%%s;
  my($info) = $1;
  if ($bad{$info}) {next;}
  debug("INFO: $info");


  # cleanup "| OkCupid" at end
  $info=~s/\s*\|\s*okcupid\s*$//i;
  ($hash{name},$hash{age},$hash{location}) = split(/\s*\/\s*/,$info);

  while ($all=~s%<dl>(.*?)</dl>%%s) {
    my($data) = $1;

    $data=~s%<dt>\s*(.*?)\s*</dt>\s*<dd.*?>\s*(.*?)</dd>%%;
    my($key,$val) = ($1,$2);
    $key=~s/\s+//g;
    $hash{lc($key)} = $val;
  }

  my(@print) = ();
  for $j (0..$#fields) {push(@print, $hash{$fields[$j]});}
  print join("|",@print),"\n";
  
  # just to make things easier to read
#  $all=~s/>/>\n/sg;
#  debug("ALL: $all");
}
