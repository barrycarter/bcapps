#!/bin/perl

# Parses a fetlife message so it can be reposted, preserving at least
# some of the original markup

require "/usr/local/lib/bclib.pl";

my($all,$fname) = cmdfile();

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
  $time=~s/\s*\+0000/UTC/;
  $text=~s/\n/ /sg;
  $text=~s/^\s*//;
  $text=~s/\s*$//;
  $text=~s/<p>/\n\n/g;
  $text=~s%</p>%\n%g;
  $text=~s%<br>%\n\n%g;
  $text=~s%<blockquote>(.*?)</blockquote>%> $1%sg;
  $text=~s/<.*?>//sg;

  print << "MARK";
**[http://fetlife.com/users/$uno][$una]** (*$time*)

$text

MARK
;
}
