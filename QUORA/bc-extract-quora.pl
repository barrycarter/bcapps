#!/bin/perl

# Given the HTML in a quora log entry like
# https://www.quora.com/log/revision/144239526, extract date and text

# --machine: print timestamp and revid in machine format (for graphing/etc)

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {

  my($all);
  if ($i=~/\.bz2$/) {
    $all = join("",`bzcat $i`);
  } else {
    $all = read_file($i);
  }

  # delete everything up to the revision number's appearance in the file
  unless ($all=~s%^.*Revision #(\d+)</h1>%%s) {
    warn "NO NUMBER: $i";
    next;
  }

  my($rev) = $1;

  # possibly useful information
  unless ($all=~s%</strong><div class="(.*?)"><div class="feed_item_activity light">(.*?) by <%%) {
    warn "No extra info found";
  }

  my($e1,$e2) = ($1,$2);

  # full url is https://quora.com/ + below
  $all=~s%href="(.*?)"%%;
  my($url) = $1;

  # TODO: check for multiple users
  $all=~s%href="/profile/(.*?)"%%;
  my($user) = $1;

  # epoch_us can appear multiple times, we want least value (when log
  # file actually "created" for first time; in pratice, it appears
  # more than once less than 5% of the time
  my(@times) = ();
  while ($all=~s%"epoch_us": (\d+),%%) {push(@times, $1);}
  my($origtime) = min(@times);
  $time = strftime("%Y%m%d.%H%M%S",gmtime(int($origtime/1000000)));

  $all=~s%<span\s+class="rendered_qtext">(.*?)</span>%%is;
  my($q) = $1;

  $all=~s%<div class="revision">(.*?)</div><p class="log_action_bar">%%s;
  my($text) = $1;
  $text=~s/<.*?>//sg;
  $text=~s/[^ -~]//g;
  $text=wrap($text,70);

  if ($globopts{machine}) {print "$origtime $rev\n"; next;}

print << "MARK";
Rev: $rev
Time: $time
Event: $e2
User: $user
Origtime: $origtime
URL: $url
Question: $q

Text: $text

MARK
;
}

=item comment

Different types of notifications (all of these come right after </strong>)

comment edited:

<div class="CommentEditOperationView AnswerCommentEditOperationView DiffView CommentOperationView"><div class="feed_item_activity light"><a href="/How-do-you-find-the-good-in-the-really-bad/answer/Jordan-Yates-4/comment/23684641">Comment</a> edited by <span id="NrNVPZ"><div class="hover_menu hidden white_bg show_nub" id="__w2_COycNCt_menu"><div class="hover_menu_contents" id="__w2_COycNCt_menu_contents"> </div></div><span id="__w2_COycNCt_link"><a class="user" href="/profile/Heidi-Embrey" action_mousedown="UserLinkClickthrough" id="__w2_COycNCt_name_link">Heidi Embrey</a>

answer wiki edited:

<div class="EditAnswerWikiOperationView DiffView"><div class="feed_item_activity light">Answer wiki edited by <span id="rZmDzN"><div class="hover_menu hidden white_bg show_nub" id="__w2_Rkb9jG1_menu"><div class="hover_menu_contents" id="__w2_Rkb9jG1_menu_contents"> </div></div><span id="__w2_Rkb9jG1_link"><a class="user" href="/profile/Barrty-Alan" action_mousedown="UserLinkClickthrough" id="__w2_Rkb9jG1_name_link">Barrty Alan</a>

answer added:

<div class="DiffView AttachAnswerOperationView"><div class="feed_item_activity light"><a href="/What-is-the-capital-of-Finland/answer/Arpan-Ghosh-19">Answer</a> added by <span id="rOWqUp"><div class="hover_menu hidden white_bg show_nub" id="__w2_C0ckCcP_menu"><div class="hover_menu_contents" id="__w2_C0ckCcP_menu_contents"> </div></div><span id="__w2_C0ckCcP_link"><a class="user" href="/profile/Arpan-Ghosh-19" action_mousedown="UserLinkClickthrough" id="__w2_C0ckCcP_name_link">Arpan Ghosh</a>



=cut
