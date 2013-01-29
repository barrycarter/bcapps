#!/bin/perl

# scrapes *recent* email addresses (*initial* post less than week old
# + no new posts?)  off scamwarners.com (selected forums) and adds
# them to toping.txt

# The fora:
# 7: advance fee fraud
# 12: lottery scams
# 14: recovery scams
# 8: charity scams
# 9: financial, various

require "/usr/local/lib/bclib.pl";

# download fora first pages (only)
for $i (7,8,9,12,14) {
  my($out,$err,$res) = cache_command("curl 'http://www.scamwarners.com/forum/viewforum.php?f=$i'", "age=3600");

  # the messages...
  while ($out=~s%<dl.*?>(.*?)</dl>%%s) {
    $post = $1;

    # the title
    $post=~s%class="topictitle">(.*?)</a>%%;
    $title = $1;

    # TODO: add date based restrictions
    while ($title=~s/([\w\.\-]+\@[\w\.\-]+)//) {
      $isemail{$1} = 1;
    }
  }
}

print join("\n", sort keys %isemail),"\n";




