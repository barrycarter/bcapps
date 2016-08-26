#!/bin/perl

# Trivial script that grabs question titles from email subjects like:
# New answer to "[title of question]"
# In Alpine: select all emails with participant quora, export to file;
# do NOT pipe to grep "Subject:" or similar because that cuts off subjects

require "/usr/local/lib/bclib.pl";

my(%qs);

# the following are uninteresting

@bad = ("upvoted your answer to: ", "followed you on Quora",
	"requested your answer to a question");

my($reg) = join("|",@bad);

debug("REG: $reg");

while (<>) {

  chomp;

  # silently skip anything that's not a subject
  unless (/^Subject: /) {next;}

  # all of these things not interesting either
  if
    (/(upvoted your answer to: |followed you on Quora|
       requested your answer to a question$)/x) {next;}

  if (/(replied to your comment on|new answer to|commented on your answer )\s*\"(.*)\"/i) {
    $qs{$2} = 1;
    next;
  }

  debug("THUNK: $_");
}
