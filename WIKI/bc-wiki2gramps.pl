#!/bin/perl

# attempts to convert http://fullhouse.wikia.com to family tree using XML dl

require "/usr/local/lib/bclib.pl";

# TODO: consider GEDCOM format to add even more info?

# TODO: custom fields in gramps?

# TODO: this is only 4M so I can read it into memory, not generally true
my($all) = join("", `bzcat fullhouse_pages_current.xml.bz2`);

# test to find "bad" character templates non trivial to parse

while ($all=~s/{{Character\s+(.*?)}}//s) {
  debug("GOT: $1");
}

die "TESTING";

# while ($all=~s/\[\[([^\[\]]*)\]\]/parse_brackets($1)/se) {}
while ($all=~s/{{([^\{\}]*)}}/parse_braces($1)/se) {}

die "TESTING";

# TODO: could print one off?
# where to store data
my(@hashes);

# the hash converting wiki field names to gramps field names
# TODO: make this more sophisticated
my(%convert) = (
 # TODO: process name into pieces
 "Firstname" => "Firstname",
 "Lastname" => "Lastname",
 "Birth" => "Birthdate",
 "Portrayer" => "Note",
 "Gender" => "Gender",
 "Death" => "Deathdate"
);

# TODO: might be better to use gramps field names?
# wiki names for fields I want
my(@fields) = ("Firstname", "Lastname", "Birth", "Portrayer", "Gender",
	      "Death");

my(@header) = @fields;
map($_=$convert{$_}, @header);
print join(",", @header),"\n";

# NOTE: The "character" template is specific to this wiki

# TODO: this is imperfect and catches tests/examples but ok for now
# TODO: this can end if there is a "}}" inside the template
# while ($all=~s/{{Character(.*?)}}//s) {

while ($all=~s/{{Character\n(.*?)\n}}//s) {

  debug("<GOT>",$1,"</GOT>");

  my($data) = $1;
  my(@csv);
  my(%hash);

  # TODO: why doesnt my later regex catch this, shouldnt have to do this!
  $data=~s/^\|(.*?)\s*\=\s*$//mg;

  while ($data=~s/^\|(.*?)\s*\=\s*(.*?)$//m) {
    debug("$1 -> $2");
    $hash{$1}=$2;
#    debug("DATA: $data");
  }

  # TODO: fix (on original wiki) cases where remainder is non empty
  $data=~s/\s+/ /g;
  if ($data=~/\S/) {debug("REMAINDER: $data, PAGE: $hash{Name}")};

  # NOTE: see which keys are most freq used
#  for $i (keys %hash) {debug("KEY: *$i*");}

  # process hash

  # first word is first name
#  debug("NAME: $hash{Name}");
  if ($hash{Name}=~s/^(\S+)\s*//) {
    $hash{Firstname} = $1;
  } else {
    $hash{Firstname} = "?";
  }

  # last word is last name
  if ($hash{Name}=~s/(\S+)$//) {
    $hash{Lastname} = $1;
  } else {
    $hash{Lastname} = "?";
  }

  # ignore totally empty names
  if ($hash{Firstname} eq "?" && $hash{Lastname} eq "?") {next;}

  # TODO: middle name is remainder?

  for $i (@fields) {
    # get rid of links
    $hash{$i}=~s/[\[\]]//g;
    # must quote since dates can have embedded commas
    push(@csv, qq%"$hash{$i}"%);
  }

  print join(",", @csv),"\n";

}

# debug("ALL: $all");

# subroutine specific to this program, not general
sub parse_braces {
  my($text) = @_;

  # TODO: assuming last argument to template is text value, not really true

  unless ($text=~s/character\s+//i) {
    $text=~s/^.*\|//;
    return $text;
  }

  debug("ALPHA: $text");

  # fix bracketed text with |s
  $text=~s/\[\[.*\|(.*?)\]\]/$1/g;

  # and without
  $text=~s/\[\[(.*?)\]\]/$1/g;

  debug("BETA: $text");
}

sub parse_brackets {
  my($text) = @_;

#  debug("PARSE_BRACKETS($text)");

  # TODO: this is bad

  # get rid of anything up to | if there is one
  $text=~s/^.*?\|//;

  return $text;

}

=item comments

Examples where parsing is hard (in Fuller House file):

|Portrayer= {{WL|Virginia Williams

must remove embedded braces AND embedded pipe symbols

=cut
