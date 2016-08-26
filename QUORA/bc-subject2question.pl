#!/bin/perl

# Trivial script that grabs question titles from email subjects like:
# New answer to "[title of question]"

# In Alpine: select all emails from comment-noreply@quora.com quora,
# export to file; do NOT pipe to grep "Subject:" or similar because
# that cuts off subjects


=item comment

Quora sends people email as the following

From: "Rory (Quora)" <appeals+bnbr@quora.com>
From: Janet Go <research@quora.com>
From: Quora <answer-noreply@quora.com>
From: Quora <comment-noreply@quora.com>
From: Quora <follow-noreply@quora.com>
From: Quora <noreply@quora.com>
From: Quora <upvote-noreply@quora.com>
From: Quora Messages <messages-noreply@quora.com>
From: Quora People You Follow <network-noreply@quora.com>
From: Quora Session Recap <sessions-noreply@quora.com>
From: Quora Weekly Digest <digest-noreply@quora.com>
From: Write on Quora <write-noreply@quora.com>

In Alpine, select emails from "answer-noreply@quora.com",
"comment-noreply@quora.com", "<noreply@quora.com" [angle bracket is
important, otherwise includes addresses that have noreply as a
substring]. Sample commands (you must have advanced features enabled
and be in your mailbox with no messages selected):

;tfanswer-noreply@quora.com
;btfcomment-noreply@quora.com
;btf<noreply@quora.com
aetemp.txt

=cut

require "/usr/local/lib/bclib.pl";

my(%qs);

# the following are uninteresting

# TODO: should comments on my post be considered interesting? (and
# suggested an edit is also contentious)

# NOTE: some near duplicates below (eg, the first two) are because
# quora has changed the format of its emails over the years

@bad = (
	"upvoted your answer to: ",
	"upvoted your answer to ",
	"voted up your answer to ",
	"followed you on Quora",
	" is now following you on Quora\$",
	"requested your answer to a question",
	"asked you to answer ",
	"Can you answer this question about ",
	"asked you to answer a question",
	"sent you a message on Quora",
	"Can you answer this question?",
	"commented on your post",
	"Question added to the topic ",
	"mentioned you in an answer",
	"suggested an edit for your answer to ",
	"more people followed you in the past",
	"Open Question about ",
	"wants an answer to this question about ",
	"is following this question about ",
	"Subject: Can you answer",
	"Subject: Question redirected: ",
	" asked you to review ",
	" promoted "
       );

# the following are interesting

@good = ("replied to your comment on", "new answer to", 
	 "commented on your answer",
	 "Quora Moderation collapsed your answer to:",
	 "Quora Moderation has flagged your answer to",
	 "recently answered", "commented on",
	 "Subject: Your answer was flagged as needing improvement on ",
	 "suggested a move for your answer to ",
	 "suggested a move for your answer from ",
	 "wrote an answer you requested to ",
	 "Subject: New comment on "
	);


my($bad) = join("|",@bad);
my($good) = join("|",@good);

while (<>) {

  chomp;

  # silently skip anything that's not a subject
  unless (/^Subject: /) {next;}

  # and uninteresting things
  if (/$bad/) {
    debug("IGNORING: $_");
    next;
  }

  if (/($good)\s*\"(.*)\"/i) {$qs{$2}++;}
}

for $i (sort {$qs{$b} <=> $qs{$a}} keys %qs) {
  print "$qs{$i} $i\n";
}


