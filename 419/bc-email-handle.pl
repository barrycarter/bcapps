#!/bin/perl

# Runs automated checks on emails and buddy lists and *recommends*
# actions, but does not do anything automatically (intentional to
# avoid mistakes)

require "/usr/local/lib/bclib.pl";

# other than '@', characters that can appear in an email
# TODO: there has to be something canon for this
$cc="/[a-z]";

# get all email addresses used in all dudmail scambaiting
# TODO: below could break if dir gets big, but it probably wont
for $i (glob "/home/barrycarter/mail/dudmail/*") {
  open(A,$i);

  while(<A>) {
    chomp;
    # skip references/etc: lines
    if (/^(references|x-yahoo-newman-id|message-id):/i) {next;}
    $orig = $_;
    # hack to find email addresses, could do better
    while (s/([\w\.]+\@[\w\.]+\.[\w\.]+)//) {
#      debug("EMAIL($orig): $1");
      $dudmail{$1}=1;
    }
  }

  close(A);
}

debug(%dudmail);

