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

  # a little bit at a time for now
  $n++;
  print "N: $n\n";
  # NOTE: thru 1000 done, rest still to go
  unless ($n>=901 && $n<=1000) {next;}

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

  # add question
  $body = "$ques\n\n$body";

  # remove (you): from title (but not other names)
  $ques=~s/^\(you\):\s*//isg;

  $body = "$body\n\n[Vark assigned category: <b>$subj</b>, <a target='_blank' href='http://wordpress.barrycarter.info/index.php/more-details-about-barry-after-vark/'>more details</a>]\n";

  # find the new (draft) post ids + open page in firefox
  $res = post_to_wp($body, "site=wordpress.barrycarter.info&author=barrycarter&password=$wordpress{pass}&subject=$ques&timestamp=$time&category=Barry After Vark");
  $res=~m%<string>(\d+)</string>%||warn("Could not parse res: $res");
  $id = $1;

  system("/root/build/firefox/firefox -remote 'openURL(http://wordpress.barrycarter.info/?p=$id&preview=true)'");

  debug("RES: $res");

  debug("<body>\n$body\n</body>");

  # use the body pretty much as is?
  debug("<ques>\n$ques\n</ques>");

}


