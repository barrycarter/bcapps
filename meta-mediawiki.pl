#!/bin/perl

# Given a page formatted as sample-data/metamedia.txt, create multiple
# semantic Mediawiki pages reflecting the relations.

# -test: use hardcoded data

# Formats:

# CASE ONE: [[foo!!bar]]: add text "bar" to page "foo", return "bar"
# to calling page, but, in bar: convert [[x::y]] to [[y]] and [[x:y]]
# to [[:x:y]] (eg, change category inclusion to category link)

# CASE TWO: [[foo!!bar|alt]]: add text "bar" (not "bar|alt") to page
# "foo", return "alt" to calling page

# NOTE: as of now, adding to non-main pages fails (but I'm ok w/ that)

# TODO: pretty sure I can seriously improve coding here (entire program)

push(@INC,"/usr/local/lib");
require "bclib.pl";

# TODO: does not create the "page of itself"

# no need for pw, edits will be anon but from 127.0.0.1 only
# "constant"
# both of these could/should be sent by hooks.php
$wiki = "wiki3.94y.info";
$pname = "Sample";

if ($globopts{test}) {
  $pagename="Page Name";
  $all = read_file("sample-data/anno1.txt");
  goto TEST;
}

$pagename = read_file($ARGV[0]);

# mediawikifs not that great, using api
($all, $err, $res) = cache_command("curl 'http://$wiki/api.php?action=query&prop=revisions&rvprop=content&format=xml&titles=$pagename'");

# remove XML (hopefully no embedded <rev> tags) [if no revs, $all is empty]
if ($all=~m%<rev[> ].*?>(.*?)</rev>%is) {$all = $1;} else {$all = "";}

TEST:

# treat the whole page as addition to itself
chomp($all);

$mainpage = $pagename;
# TODO: genearlize below
$mainpage =~s/^Sample://;
$all = "[[$mainpage!!$all]]";

# the tags I use to recognize the sections I create on other pages
# <h>yes, I realize I use this as a my() var in a subroutine; ha ha</h>
# TODO: create much better tags
# NOTE: using escapeable characters will cause probs w later recognition
($stag, $etag) = ("-$pagename-", "-$pagename-");

# parse all [[foo]] and {{foo}} on page (I don't use {{foo}}, but it
# needs to be protected

# TODO: this matches [[foo}} (which it shouldn't)
# this builds %add which tells us what to add to which pages
while 
  ($all=~s/(\[\[?|\{\{?)([^\[\]\{\}]*?)(\]\]?|\}\}?)/parse_text($1,$2,$3)/iseg) {
  $round++;
}

# TODO: this is hideous (so turning off)
# open(A,"|parallel -j 20");

# "add" things to pages as needed (actually, replace existing section)
for $i (sort keys %add) {
  debug("I: $i");
  @add = @{$add{$i}};

  for $j (@add) {
    debug("I: $i, J: $j");
  # parse $n s$n p$n as above
    $j=~s/<<s?(\d+)>>/$text[$1]/isg;
    $j=~s/<<p(\d+)>>/convert_text($text[$1])/iseg;
  }

  # content generated from $pagename for page $i
  # TODO: improve this
#  debug("ADD",@add);
  $content = join("<br>",@add);

  # and reset @{$add{$i}}
  # TODO: modify list directly, no middle step
  @{$add{$i}} = @add;

  # pull this page from the wiki (ok if it doesnt exist)
  # TODO: escape title if needed
  $iurl = urlencode($i);
  ($page, $err, $res) = cache_command("curl 'http://$wiki/api.php?action=query&prop=revisions&rvprop=content&format=xml&titles=$iurl'");
#  debug("PAGE1: $page");
  if ($page=~m%<rev[> ].*?>(.*?)</rev>%is) {$page = $1;} else {$page = "";}
#  debug("PAGE2: $page");
#  debug("CONTENT: $content");

  # Case 1: this page had previously created a section and will replace it
  unless ($page=~s%($stag)(.*?)($etag)%$1\n$content\n$3%s) {
    # Case 2: didn't already have it, so add it
    debug("$i doesn't have $stag/$etag, so adding psuedosection");
#    debug("CONTENT($i): $page");
    $page = "$page\n$stag$content$etag\n";
  }

  debug("NEW $i: $page");

  $res = write_wiki_page_anon($wiki, $i, $page, "AUTO");

#  debug("RES: $res");
#  debug("PAGE3: $page");

  debug("ADD($i)", @add);

  print "$res\n";
#  print A "$res\n";
}

# close(A);

sub parse_text {
  my($stag, $text, $etag) = @_;
#  debug("PARSE_TEXT($stag$text$etag)");

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
  if ($text=~/^(.*?)\!\!(.*?)$/s) {
    my($page, $info) = ($1,$2);

    # if $info contains any <<s$n>>, parse them immediately, but keep
    # original version (w/ s removed) to return to calling page
    my($originfo) = $info;
    # p$n indicates "parsed once already"
    $originfo=~s/<<s(\d+)>>/<<p$1>>/isg;
    $info=~s/<<s(\d+)>>/$text[$1]/isg;

    # %add is a global hash (of lists)
    push(@{$add{$page}}, $info);
    return $originfo;
  }

  warn "SHOULD NEVER REACH THIS POINT!";
  return "";
}

# convert tags with colons (they display differently on calling page
# and called page

sub convert_text {
  my($text) = @_;
#  debug("GOT: $text");

  # special case: [:Category:Foo] (don't change!)
  if ($text=~/^\[\[:/) {return $text;}

  # colon fixing
  $text=~s/\[\[(.*?)::?(.*)\]\]/[[$2]]/isg;

#  debug("RET: $text");
  return $text;
}

# Retursn the command to write wiki page when no login is required
# (faster). Results can be run using GNU parallel

# TODO: limit anon writes to 127.0.0.1

sub write_wiki_page_anon {
  my($wiki, $page, $newcontent, $comment)= @_;

  # use map() below?
  ($page, $newcontent) = (urlencode($page), urlencode($newcontent));

  # write newcontent to file (might be too long for command line)
  my($tmpfile) = "/tmp/".sha1_hex("$user-$wiki-$page");

  # Could use multiple -d's to curl, but below is probably easier
  write_file("action=edit&title=$page&text=$newcontent&summary=$comment&token=%2B\\", $tmpfile);

  # can't cache this command, but using cache_command to get vals
  return "curl '$wiki/api.php?format=xml' -H 'Expect:' -d \@$tmpfile";
}


=item schema

Schema for metatab table

CREATE TABLE metatab (creator, page, info);

=end
