#!/bin/perl

# Given a page formatted as README, create multiple semantic Mediawiki pages

require "/usr/local/lib/bclib.pl";

my($data,$fname) = cmdfile();

# TODO: "tokenizing" here is ugly and probably breaks Unicode or something
$data=~s%</add>%\x01%g;
$data=~s%<add page="(.*?)">%\x02$1\x02%g;

debug("DATA: $data");

while ($data=~s%\x02([^\x01\x02]*?)\x02([^\x01\x02]*?)\x01%$2%is) {
  my($page,$add) = ($1,$2);
  debug("PAGE: $page, ADD: $page $add");
}

die "TESTING";

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
