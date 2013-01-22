#!/bin/perl

# downloads dudmail to a Unix-style mail folder

require "/usr/local/lib/bclib.pl";

# this is an actual 419 bait account I created
$acct = "leonard.zepowitz";
$url = "http://dudmail.com/for/$acct";

# by its nature, dudmail has no passwords
# TODO: reduce/omit age= after testing
my($out,$err,$res) = cache_command("curl http://dudmail.com/for/$acct","age=3600");

while ($out=~s%href="/emails/(\d+)"%%is) {
  my($url) = $1;
  $url = "http://dudmail.com/emails/$url?mailbox=$acct&type=original_source";
  # this cache can be longer, message doesnt change once received
  my($out2,$err2,$res2) = cache_command("curl '$url'","age=86400");
  # find message content
  $out2=~m%<pre id='email_source'>(.*?)</pre>%s || warn("NO MESSAGE?:");
  $msg = $1;
  # TODO: check for duplicates, dont add msgs many times (but just testing now)
  append_file($msg, "/home/barrycarter/mail/dudmail/test");
}

