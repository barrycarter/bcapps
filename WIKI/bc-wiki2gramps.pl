#!/bin/perl

# attempts to convert http://fullhouse.wikia.com to family tree using XML dl

require "/usr/local/lib/bclib.pl";

# TODO: this is only 4M so I can read it into memory, not generally true
my($all) = join("", `bzcat fullhouse_pages_current.xml.bz2`);

# TODO: could print one off?
# where to store data
my(@hashes);

# what data to export
my(@fields) = ("Name", "Birth", "Portrayer");

# TODO: not sure gramps willr recognize these fields, so change if needed
print join(",", @fields),"\n\n";

# NOTE: The "character" template is specific to this wiki

# TODO: this is imperfect and catches tests/examples but ok for now
while ($all=~s/{{Character(.*?)}}//s) {

  my($data) = $1;
  my(@csv);
  my(%hash) = ();
  while ($data=~s/\|(.*?)\s*\=\s*(.*?)\s*$//) {
    $hash{$1} = $2;
  }

  for $i (@fields) {
    # get rid of references
    $hash{$i}=~s/[\[\]]//g;
    # must quote since dates can have embedded commas
    push(@csv, qq%"$hash{$i}"%);
  }

print join(",", @csv),"\n";

}

# debug("ALL: $all");

