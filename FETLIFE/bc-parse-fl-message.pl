#!/bin/perl

# Parses a fetlife message so it can be reposted, preserving at least
# some of the original markup

require "/usr/local/lib/bclib.pl";

my($all,$fname) = cmdfile();

# need title to find group name (+ also original URL)
$all=~s%<title>(.*?)</title>%%s;
my($htmltitle) = $1;
$htmltitle=~s/.* \- (.*?) \- FetLife//s;
my($group) = $1;

$all=~s%The material appears at the following website addresses: (.*?)</p>%%;
my($url) = $1;

# group number
$url=~m%/groups/(\d+)/%;
my($gnum) = $1;

# original message
$all=~s/<div class="group_post clearfix">(.*?)<div id="group_post_comments_container" class="discussion_container">//s;

my($post) = $1;

# extract title/time/etc
$post=~s%<h3>(.*?)</h3>%%s;
my($title) = $1;

# find group name from HTML title


# this wipes out everything above the post too (so we have just the
# message left?) and the (useless) date info

$post=~s%^.*?by <a href="https://fetlife.com/users/(\d+)" class="quiet">(.*?)</a>.*?</p>%%s;

my($uno, $una) = ($1,$2);

$post = text_cleanup($post);
$post=~s/^\s*//g;
$post=~s/\s*$//g;

print << "MARK";
Original URL: $url

## [$group][http://fetlife.com/groups/$gnum]

### $title
#### by [http://fetlife.com/users/$uno][$una]
---
$post

#### Responses
---
MARK
;

while ($all=~s%<article[^>]*?>(.*?)</article>%%is) {
  my($comment) = $1;

  # user id and name
  $comment=~s%<a href="https://fetlife.com/users/(\d+)" class="nickname">(.*?)</a>%%s;
  my($uno,$una) = ($1,$2);

  # time (TODO: decide if I want this GMT or local for person saving file)
  $comment=~s/datetime="(.*?)"//;
  my($time) = $1;

  # and the comment itself
  $comment=~s%<div class="content">(.*?)</div>%%s;
  my($text) = $1;

  # cleanups
  $time=~s/\s*\+0000/ UTC/;
  $text = text_cleanup($text);

  # text cleanups
  print << "MARK";
**[http://fetlife.com/users/$uno][$una]** (*$time*)

$text

MARK
;
}

# subroutine specific to this program
sub text_cleanup {
  my($text) = @_;

  debug("ALPHA: $text");
  $text=~s/\xe2\x80\xa6/.../g;
  # TODO: this doesn't work well if both $1 and $2 are links
  $text=~s%<a href="(.*?)"[^>]*>([^<]*?)</a>%[$1][$2]%g;
  debug("BETA: $text");
  $text=~s/\n/ /sg;
  $text=~s/^\s*//;
  $text=~s/\s*$//;
  $text=~s/<p>/\n\n/g;
  $text=~s%</p>%\n%g;
  $text=~s%<br>%\n\n%g;
  $text=~s%<blockquote>(.*?)</blockquote>%> $1%sg;
  $text=~s/<.*?>//sg;
  # this must happen last
  $text=~s/\&lt\;/</g;
  $text=~s/\&gt\;/>/g;
  $text=~s/\&amp\;/&/g;
  $text=~s/\xe2\x80\x93/-/g;
  $text=~s/\xe2\x80\x99/'/g;

  return $text;
}
