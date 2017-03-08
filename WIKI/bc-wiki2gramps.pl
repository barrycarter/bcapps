#!/bin/perl

# attempts to convert http://fullhouse.wikia.com to family tree using XML dl

require "/usr/local/lib/bclib.pl";

# TODO: consider GEDCOM format to add even more info?

# TODO: this seems unneccesarily complicated/complex

# TODO: custom fields in gramps?

my(%ignored);

# TODO: this is only 4M so I can read it into memory, not generally true
my($all) = join("", `bzcat fullhouse_pages_current.xml.bz2`);

# the hash converting wiki field names to gramps field names
# TODO: make this more sophisticated
my(%convert) = (
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

# strictly speaking, don't need to parse page-by-page, but cleaner?

while ($all=~s%<page>(.*?)</page>%%s) {
  my($page) = $1;

  $page=~s%<title>(.*?)</title>%%s;
  my($title) = $1;

  # ignore all "colon" pages, but do keep track
  if ($title=~s/^(.*?)://) {$ignored{$1} = 1; next;}

  # if no character template (TODO: this is SO hacky!), ignore
  # the \ below aren't necessary, but help emacs format
  unless ($page=~m/\{\{Character\s/s) {next;}

  # possibly a bad idea, but annoying otherwise
  $page = html_unescaped($page);

  # fix bracketed text with |s
  $page=~s/\[\[.*\|(.*?)\]\]/$1/g;

  # and without
  $page=~s/\[\[(.*?)\]\]/$1/g;

  # process all templates (including Character)
  while ($page=~s/{{([^\{\}]*)}}/parse_braces($1)/se) {}
}

# debug(sort keys %ignored);

# TODO: could print one off?
# where to store data
my(@hashes);

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

  # it's a character, so parse and remove
  parse_character($text);
  return;
}


sub parse_character {
  my($text) = @_;
  my(%hash,@csv);

  # this makes 'split'ting easier, but also fixes bad newlines
  $text=~s/\n/ /g;

  my(@fs) = split(/\|/s,$text);

  for $i (@fs) {
    # this sets $2 to blank if nothing to right of equal sign
    $i=~s/^\s*(.*?)\s*\=\s*(.*?)\s*$//;
    $hash{$1} = $2;
  }

  # process hash

  my(@names) = split(/\s+/, $hash{Name});

  # if more than one name, last word is last name, all else is first
  if (scalar(@names)>1) {
    $hash{Firstname} = join(" ", @names[0..$#names-1]);
    $hash{Lastname} = $names[-1];
  } else {
    # if only one name, its the first name
    $hash{Firstname} = $names[0];
    $hash{Lastname} = "?";
  }

  for $i (@fields) {
    # must quote since dates can have embedded commas
    push(@csv, qq%"$hash{$i}"%);
  }

  print join(",", @csv),"\n";
}

# TODO: add this func to bclib
sub html_unescaped {

  my($text) = @_;
  $text=~s/&lt;/</g;
  $text=~s/&gt;/>/g;
  $text=~s/&amp;/&/g;
  $text=~s/&quot;/"/g;
  return $text;

}


=item comments

Examples where parsing is hard (in Fuller House file):

|Portrayer= {{WL|Virginia Williams

must remove embedded braces AND embedded pipe symbols

=cut
