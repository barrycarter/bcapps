#!/bin/perl

# extracts PBS transcripts from pages like http://www.icoolen.com/cartoon_single/pearlpig_2002_01

require "/usr/local/lib/bclib.pl";

for $i (glob "/home/barrycarter/20140518/pearlpig_*") {
  # determine start date from file name
  unless ($i=~/pearlpig_(\d{4})_(\d{2})/) {die "BAD FILE: $i"}
  $date = "$1-$2-01";

  $all = read_file($i);

  while ($all=~s/<div style="line-height: 150%">(.*?)<\/div>//) {
    $text = $1;


    debug("TEXT: $text");

    # site above uses gray for Chinese characters
    if ($text=~/color: gray/) {next;}

    # if not chinese, cleanup...
    $text=~s/&nbsp;/ /g;
    $text=~s/&rsquo;/'/g;
    $text=~s/&hellip;/.../g;
    $text=~s/&mdash;/--/g;
    # we don't distinguish between left and right quotes, though we could
    $text=~s/&([lr]dquo|quot);/\"/g;
    $text=~s/&[lr]squo;/\'/g;

    # remove HTML tags and unprintables
    $text=~s/<.*?>//g;
    $text=~s/[^ -~]//g;

    # convert escaped HTML
    $text=~s/&lt;/</;
    $text=~s/&gt;/>/;

    # if nothing left, ignore
    if ($text=~/^\s*$/) {next;}

    # if this is a date, note it
    if ($text=~/^\d{4}-\d{2}-\d{2}$/) {$date = $text; next;}

    print "$date: $text\n";
  }
}

# debug($all);

# TODO: catch format below for dates (only appears to be for dates)
# <span style="color: #00afe1">2002-06-03</span>
