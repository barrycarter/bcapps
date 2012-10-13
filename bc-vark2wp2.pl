#!/bin/perl

# vark.com shutdown a while back and promised everyone a dump of their
# data; I finally got mine; this script parses the vark log into
# unapproved WP posts, similar to vark2wp.pl, but non-identical

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

$data = read_file("/home/barrycarter/VARK-carter_barry-at-gmail_com.txt");

# warn "TESTING"; $data = read_file("/tmp/vark2.txt");

# split into questions (each starts with "*something*")

@qs = split(/(\n\*[^\*\n]*?\*\n\d{4}-\d{2}\-\d{2} \d{2}:\d{2}:\d{2}) UTC\n/s, $data);

# get rid of pointless header
shift(@qs);

while (@qs) {
  ($head, $body) = (shift(@qs), shift(@qs));

  # randomly choose
  unless (rand()<.001) {next;}

  # date and varks bizarre "subject"
  $head=~/\*(.*?)\*\n(.*)/||warn("BAD HEAD: $head");
  ($subj, $time) = ($1, $2);
  $time = str2time($time);

  # extract question part (may be from other person if I am answerer)
  $body=~s/^(.*?)\n\-?\-?\n?//||warn("BAD BODY: $body");
  $ques = $1;

  # cleanup body
  $body=~s/\n/\n\n/isg;
  $body=~s/</\&lt\;/isg;
  $body=~s/>/\&gt\;/isg;
  $body=~s/\n\-\-\n/\n----------------------\n/isg;

  # if empty...
  if ($body=~/^\s*$/) {
    $body = "[I asked this question on vark.com, but never received an answer]\n";
  }

  # and subject (but only if I asked question
  $ques=~s/^\(.*?\):\s*//isg;

#  if (++$n>1) {die "TESTING";}

  # using vark-new to avoid confusion (for now)
  post_to_wp($body, "site=wordpress.barrycarter.info&author=barrycarter&password=$wordpress{pass}&subject=$ques&timestamp=$time&category=Barry After Vark");

  debug("<body>\n$body\n</body>");

  # use the body pretty much as is?
  debug("<ques>\n$ques\n</ques>");

}


