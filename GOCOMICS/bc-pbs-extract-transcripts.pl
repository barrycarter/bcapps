#!/bin/perl

# extracts PBS transcripts from pages like http://www.icoolen.com/cartoon_single/pearlpig_2002_01

require "/usr/local/lib/bclib.pl";

# TODO: still missing several lines due to alternate regexs

for $i (glob "/home/barrycarter/20140518/pearlpig_*") {
  # determine start date from file name
  unless ($i=~/pearlpig_(\d{4})_(\d{2})/) {die "BAD FILE: $i"}
  $date = "$1-$2-01";
  debug("FILE: $i");
  $all = read_file($i);

  # capture lines of interest
  for $j (split(/\n/, $all)) {

    # kill of chinese character lines here
    if ($j=~/color: gray/) {next;}

    # kill of uninteresting lines here
    unless ($j=~s/<div style="line-height: 150%">(.*?)<\/div>// ||
	$j=~s/<span style="color: #00afe1">(.*?)<\/span>//) {
      # even though we ignore $j, let's clean it up and look at it to
      # make sure we're not ignoring anything important
      $j = cleanup_text($j);
      # truly ignore empty
      if ($j=~/^\s*$/) {next;}
      debug("IGNORING: $j");
      next;
    }

    # cleanup text and add it
    $text = $1;
    $text = cleanup_text($text);
    # if text empty after cleanup, ignore it
    if ($text=~/^\s*$/) {next;}
    # if this is a date, set it
    if ($text=~/^\d{4}-\d{2}-\d{2}$/) {
      $date = $text;
      next;
    }
    # text by date
    push(@{$text{$date}},$text);
  }
}

for $i (keys %text) {
  # join by newline
  $text = join("\n", @{$text{$i}})."\n";
  # and write to file (so I can test w feh)
  # filename is chosen for compatibility w/ way I have GIFs stored
  write_file($text, "/mnt/extdrive/GOCOMICS/pearlsbeforeswine/TRANSCRIPTS/page-$i.gif.txt");
}

# this routine is program-specific
sub cleanup_text {
  my($text) = @_;
  $text=~s/&nbsp;/ /g;
  $text=~s/&rsquo;/\'/g;
  $text=~s/&hellip;/.../g;
  $text=~s/&mdash;/--/g;
  # we don't distinguish between left and right quotes, though we could
  $text=~s/&([lr]dquo|quot);/\"/g;
  $text=~s/&[lr]squo;/\'/g;
  # remove HTML tags and unprintables
  $text=~s/<.*?>//g;
  $text=~s/[^ -~]//g;
  return $text;
}


