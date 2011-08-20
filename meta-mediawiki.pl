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

# in theory, I could just [[pagename!!page_content]] and parse that?

# parse all [[foo]] and {{foo}} on page (I don't use {{foo}}, but it
# needs to be protected

# TODO: pretty sure I can seriously improve coding here (entire program)

# TODO: this matches [[foo}} (which it shouldn't)
while ($all=~s/(\[\[|\{\{)([^\[\]\{\}]*?)(\]\]|\}\})/parse_text($1,$2,$3)/iseg) {}

# now replace <<$n>> and any <<s$n>> not already parsed
$all=~s/<<s?(\d+)>>/$text[$1]/isg;

# and <<p$n>>
# TODO: everything
$all=~s/<<p(\d+)>>/convert($text[$1])/iseg;

# do the same for all additions to all pages
for $i (sort keys %add) {
  @add = @{$add{$i}};

  for $j (@add) {
  # parse $n s$n p$n as above
    $j=~s/<<s?(\d+)>>/$text[$1]/isg;
    $j=~s/<<p(\d+)>>/convert($text[$1])/iseg;
  }

  debug("ADD($i)", @add);
}

debug("ALL: $all");

sub parse_text {
  my($stag, $text, $etag) = @_;
  debug("PARSE_TEXT($stag$text$etag)");

  # if of form [[foo:bar]] or [[foo::bar]], it will display different
  # on calling page and called page, so mark w/ tag s$n, not just $n
  if ($text=~/^(.*?)::?(.*?)$/) {
    $text[++$n] = "$stag$text$etag";
    return "<<s$n>>";
  }

  # if no !!, replace with <<$n>> and keep track of $n
  # TODO: this is horrible; must be better way to do this!

  unless ($text=~/\!\!/) {
    # The ++$n means $text[1] is first, but saves me initialization step
    # NOTE: @text is global
    $text[++$n] = "$stag$text$etag";
    return "<<$n>>";
  }

  # handle case 2 first
  if ($text=~/^(.*?)\!\!(.*?)\|(.*?)$/) {
    my($page, $info, $alt) = ($1, $2, $3);
    # if $info contains any <<s$n>>, parse them immediately
    $info=~s/<<s(\d+)>>/$text[$1]/isg;
    return $alt;
  }

  # case 1
  if ($text=~/^(.*?)\!\!(.*?)$/) {
    my($page, $info) = ($1,$2);

    # if $info contains any <<s$n>>, parse them immediately, but keep
    # original version (w/ s removed) to return to calling page
    my($originfo) = $info;
    # p$n indicates "parsed once already"
    $originfo=~s/<<s(\d+)>>/<<p$1>>/isg;
    $info=~s/<<s(\d+)>>/$text[$1]/isg;
    push(@{$add{$page}}, $info);
    return $originfo;
  }

  warn "SHOULD NEVER REACH THIS POINT!";
  return "";
}

# convert tags with colons (they display differently on calling page
# and called page

sub convert {
  my($text) = @_;
  debug("GOT: $text");

  # special case: [:Category:Foo] (don't change!)
  if ($text=~/^\[\[:/) {return $text;}

  # colon fixing
  $text=~s/\[\[(.*?)::?(.*)\]\]/[[$2]]/isg;

  debug("RET: $text");
  return $text;
}



