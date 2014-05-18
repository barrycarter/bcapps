#!/bin/perl

# extracts PBS transcripts from pages like http://www.icoolen.com/cartoon_single/pearlpig_2002_01

require "/usr/local/lib/bclib.pl";

my($all,$fname) = cmdfile();

while ($all=~s/<div style="line-height: 150%">(.*?)<\/div>//) {
  $text = $1;
  # site above uses gray for Chinese characters
  if ($text=~/<span style=\"color: gray/) {next;}

  # if not chinese, cleanup...
  $text=~s/&nbsp;/ /g;
  $text=~s/&rsquo;/'/g;
  $text=~s/&hellip;/.../g;
  # we don't distinguish between left and right quotes, though we could
  $text=~s/&([lr]dquo|quot);/\"/g;
  $text=~s/&[lr]squo;/\'/g;

  # remove HTML tags and unprintables
  $text=~s/<.*?>//g;
  $text=~s/[^ -~]//g;
  # if nothing left, ignore
  if ($text=~/^\s*$/) {next;}

  debug("text: $text");
}

# debug($all);

