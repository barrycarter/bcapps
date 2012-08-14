#!/bin/perl

# This is a different version of meta-mediawiki that uses .mmw pages
# ('meta-media-wiki') to create .mw pages suitable for use with
# wikipediafs; however, I plan to permit direct API access as well

# This program intentionally takes an argument and does NOT
# auto-update all files in the directory for efficiency (especially
# if/when I make this real time)

# Usage: $0 <page>

require "/usr/local/lib/bclib.pl";

($data,$file) = cmdfile();

# the page name is the tail of the filename (excluding the .mmw extension)
$pagename = $file;
$pagename=~s/^.*\///;
$pagename=~s/\.mmw//;

# the meta page always adds to the wiki page it represents
$all = "[[$pagename!!$data]]";

# parse tags...
while 
  ($all=~s/(\[\[?|\{\{?)([^\[\]\{\}]*?)(\]\]?|\}\}?)/parse_text($1,$2,$3)/iseg) {
  # TODO: disallow infinite loops
  $round++;
}

# declare tags
($stag, $etag) = ("-$pagename-\n\n", "\n\n-$pagename-\n");

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
  $content = join("<br>",@add);

  # and reset @{$add{$i}}
  # TODO: modify list directly, no middle step
  @{$add{$i}} = @add;

  # pull this page from the .mw file (ok if it doesn't exist)
  # TODO: what if this is in different dir?
  if (-f "$i.mw") {
    $page = read_file("$i.mw");
  } else {
    warn("Will create $i.mw");
    $page = "";
  }

  # Case 1: this page had previously created a section and will replace it
  unless ($page=~s%($stag)(.*?)($etag)%$1\n$content\n$3%s) {
    # Case 2: didn't already have it, so add it
    debug("$i doesn't have $stag/$etag, so adding psuedosection");
#    debug("CONTENT($i): $page");
    $page = "$page\n$stag$content$etag\n";
  }

  debug("NEW $i: $page");

  # and write it
  write_file($page,"$i.mw");

#  $res = write_wiki_page_anon($wiki, $i, $page, "AUTO");

#  debug("RES: $res");
#  debug("PAGE3: $page");

  debug("ADD($i)", @add);

#  print "$res\n";
#  print A "$res\n";
}

# stolen from meta-mediawiki.pl
sub parse_text {
  my($stag, $text, $etag) = @_;

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

  die "Unparseable";
  return "";
}






