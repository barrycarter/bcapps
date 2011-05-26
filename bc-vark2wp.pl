#!/bin/perl

# attempts to find channel ids from vark dump of questions I've
# asked, with goal of posting them to WP

# NOTE: this program does very little by itself and mostly provides a
# template/list of instructions.

# Requirements:
#  iMacros for Firefox

=item dothisfirst

% Login to vark.com, go to history and choose answers or questions (as desired)

% Calculate number of pages: for example "1-7 of 1951" means there are
Ceiling[1951/7] pages.

# Run this (where 279 is the number found above)

perl -le 'for $i (1..279) {print "URL GOTO=http://vark.com/channels/questions?page=$i&format=jsonh"}' | tee ~/iMacros/Macros/vark.iim

# If updating/testing, edit/truncate resultant file above

# Run vark.iim as an iMacro inside Firefox

% Run this script with --vark2 (bc-vark2wp.pl --vark2)

% This scripts creates vark2.iim

% <h>Take a moment to admire the hideousness that is vark2.iim</h>

% Run vark2.iim as an iMacro inside Firefox

% Run this script again with --json (bc-vark2wp.pl --json)

=cut

push(@INC,"/usr/local/lib");
require "bclib.pl";
#<h>find . -type d | grep 'heart' is another way to do the below</h>
$home = $ENV{HOME};
debug("HOME: $home");

# info about my blog
$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);
$author = "barrycarter";
$wp_blog = "wordpress.barrycarter.info";

if ($globopts{vark2}) {
open(A,"> $home/iMacros/Macros/vark2.iim");

for $file (glob("$home/Download/questions*")) {
  debug("FILE: $file");
  $all = read_file($file);
  @channels = ($all=~m/data-channel_id=\\\"(.*?)\\\"/isg);

  for $j (@channels) {
    # TODO: this is bad, answers do change!
    unless (-f "$home/Download/$j") {
      print A "URL GOTO=http://vark.com/channels/$j?format=jsonh\n";
    } else {
      warnlocal("Skipping $j, already exists");
    }
  }
}

close(A);
}

if ($globopts{json}) {
  for $file (glob("$home/Download/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]")) {
    $all = read_file($file);
    debug("READING: $file");

    # find link
    if ($all=~m%vark\.com/t/(.*?)\\%isg) {$link=$1;} else {$link="";}

    # NOTE: even though $all is in JSON format, it's surprisingly
    # useless as a JSON object. Instead:
    %hash=();
    while ($all=~s%<div class=."(.*?).">(.*?)</div>%%) {
      ($key, $val) = ($1, $2);
#      debug("PRE: $key -> $val");

      # NOTE: most of the conversions below are fairly useless, since
      # the div tags (and indeed, the page itself), does not provide
      # much useful info that we couldn't get just using regexs

      # NOTE: yes, that's a literal "\n" below, not a newline
      $val=~s/\\n//isg;
      # convert hard spaces
      $val=~s/&nbsp;/ /isg;
      # strip HTML tags
      $val=~s/<[^>]*?>//isg;
      $val=~s/\s+/ /isg;
      $val=~s/\|//isg;
      $val = trim($val);
      unless ($hash{$key}) {$hash{$key} = $val;}
    }

    # convert date to Unix time; using 1200 GMT since it's almost the
    # same day everywhere then
    # <h>Of course, it's 1700 somewhere</h>
    # <h>"Take The 0000 Train to Georgia" would be a terrible song</h>
    $date = str2time("$hash{history_title} 1200 GMT");

    $content = "I asked this question on vark.com:<p><b>$hash{content}</b><p>Please answer here";

    if ($link) {
      $content = "$content, or see this question on <a target='_blank' href='http://vark.com/t/$link'>Aardvark</a>";
    }

    # shorten subject when needed
    if (length($hash{content})<=80) {
      $subject = $hash{content};
    } else {
      $subject = substr($hash{content},0,77)."...";
    }

    # cleanup
    $subject=~s/\"/&quot;//isg;

    post_to_wp($content, "site=$wp_blog&author=$author&password=$pw&subject=$subject&timestamp=$date&category=VARK");

    if ($n++ > 100) {die "TESTING";}

  }
}

