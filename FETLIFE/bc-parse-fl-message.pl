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
  $comment=~s/<time title="(.*?)"//;
  my($time) = $1;

  # and the comment itself
  $comment=~s%<div class="content">(.*?)</div>%%s;
  my($text) = $1;

  debug("C: $comment");

#  debug("$1,$2");
#  debug("C: $comment");
}

# debug("ALL: $all");

