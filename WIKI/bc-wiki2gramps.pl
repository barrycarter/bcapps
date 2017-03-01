#!/bin/perl

# attempts to convert http://fullhouse.wikia.com to family tree using XML dl

require "/usr/local/lib/bclib.pl";

# TODO: this is only 4M so I can read it into memory, not generally true
my($all) = join("", `bzcat fullhouse_pages_current.xml.bz2`);

# TODO: could print one off?
# where to store data
my(@hashes);

# the hash converting wiki field names to gramps field names
# TODO: make this more sophisticated
my(%convert) = (
 # TODO: process name into pieces
 "Name" => "Firstname",
 "Birth" => "Birthdate",
 "Portrayer" => "Note",
 "Extra" => "Lastname"
);

# TODO: might be better to use gramps field names?
# wiki names for fields I want
my(@fields) = ("Name", "Extra", "Birth", "Portrayer");

my(@header) = @fields;
map($_=$convert{$_}, @header);
print join(",", @header),"\n";

# NOTE: The "character" template is specific to this wiki

# TODO: this is imperfect and catches tests/examples but ok for now
while ($all=~s/{{Character(.*?)}}//s) {

  my($data) = $1;
  my(@csv);
  my(%hash) = ("Extra" => "Test");

  while ($data=~s/\|(.*?)\s*\=\s*(.*?)\s*$//) {
    $hash{$1} = $2;
  }

  debug("NAME IS",$hash{Name});
  for $i (@fields) {

    debug("FIELD: $i, VAL: $hash{$i}");

    # get rid of references
    $hash{$i}=~s/[\[\]]//g;
    # must quote since dates can have embedded commas
    push(@csv, qq%"$hash{$i}"%);
  }

  print join(",", @csv),"\n";

}

# debug("ALL: $all");

