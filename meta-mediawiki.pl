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

$all = read_file("sample-data/metamedia.txt");

while ($all=~s/\[\[([^\[\]]*?)\]\]/parse_text($1)/iseg) {}

debug($all);

sub parse_text {
  my($text) = @_;
  debug("PARSE_TEXT($text)");
  
  # if no !!, just change [[x]] to <<x>> (so it won't catch the regex again).
  # TODO: this is horrible; must be better way to do this!

  unless ($text=~/\!\!/) {return "<<$text>>";}

  # handle case 2 first
  if ($text=~/^(.*?)\!\!(.*?)\|(.*?)$/) {
    my($page, $info, $alt) = ($1, $2, $3);
    debug("$page ADD: $info");
    return $alt;
  }

  # case 1
  if ($text=~/^(.*?)\!\!(.*?)$/) {
    my($page, $info) = ($1,$2);
    debug("$page: $info");
    return converted($info);
  }

  warn "SHOULD NEVER REACH THIS POINT!";
  return "";
}

# convert text as per notes for case 1 above (note that [[foo]] is
# <<foo>> by this point)

sub converted {
  my($text) = @_;

  # NOTE: probably no need to recurse here, since inner levels already handled?
  $text=~s/<<(.*?)::(.*?)>>/<<$2>>/isg;
  $text=~s/<<(.*?):(.*?)>>/<<:$1:$2>>/isg;

  return $text;
}



