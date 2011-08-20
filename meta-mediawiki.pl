#!/bin/perl

# Given a page formatted as sample-data/metamedia.txt, create multiple
# semantic Mediawiki pages reflecting the relations.

# Formats:

# CASE ONE: [[foo!!bar]]: add text "bar" to page "foo", return "bar"
# to calling page, but, in bar: convert [[x::y]] to [[y]] and [[x:y]]
# to [[:x:y]] (eg, change category inclusion to category link)

# CASE TWO: [[foo!!bar|alt]]: add text "bar" (not "bar|alt") to page
# "foo", return "alt" to calling page

require "bclib.pl";

$all = read_file("sample-data/metamedia2.txt");

while ($all=~s/\[\[([^\[\]]*?)\]\]/parse_text($1)/iseg) {}

debug($all);

sub parse_text {
  my($text) = @_;
  debug("PARSE_TEXT($text)");

  # if no !!, just change [[x]] to <<x>> (so it won't catch the regex again).
  # TODO: this is horrible; must be better way to do this!

  unless ($text=~/\!\!/) {return "<<$text>>";}

  # add to page?
  if ($text=~/^(.*?)\!\!(.*?)$/) {
    my($page, $info) = ($1,$2);
    debug("$page: $info");

    # how should $info show up on the next higher-level page?
    $info = parse_tag($info);
    return $info;
  }
}

# given a tag of the format <<foo>>, parse it to return the value to
# the containing document

sub parse_tag {
  my($text) = @_;
  debug("PARSE_TAG($text)");

  # recursively parse inner tags first
  $text=~s/<<(.*?)>>/parse_tag($1)/iseg;

  # alternate text
  if ($text=~s/^(.*?)\|(.*?)$/$2/) {return $text;}

  # semantic annotations
  if ($text=~s/^(.*?)::(.*?)$/$2/) {return "<<$text>>";}

  # everything else
  return "<<$text>>";
}





