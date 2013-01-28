#!/bin/perl

# Runs automated checks on emails and buddy lists and *recommends*
# actions, but does not do anything automatically (intentional to
# avoid mistakes)

require "/usr/local/lib/bclib.pl";

open(A,"fgrep -hR @ /home/barrycarter/mail/dudmail|");

# get all email addresses used in all dudmail scambaiting
# TODO: below could break if dir gets big, but it probably wont
while(<A>) {
  chomp;
  # skip references/etc: lines (in-reply-to bad, reply-to good)
  if (/^(references|x-yahoo-newman-id|message-id|in-reply-to):/i) {next;}
  $orig = $_;
  # hack to find email addresses, could do better
  while (s/([\w\.]+\@[\w\.]+\.[\w\.]+)//) {
    $addr = $1;
    # this is hideous; references: hack doesnt get everything, this prunes
    # by knowing .gbl isnt a TLD (blech)
    if ($addr=~/\.gbl/) {next;}
    #      debug("EMAIL($orig): $1");
    $dudmail{$1}=1;
  }
}

close(A);

debug(%dudmail);
