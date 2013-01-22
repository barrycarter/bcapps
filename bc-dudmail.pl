#!/bin/perl

# downloads dudmail to a Unix-style mail folder

require "/usr/local/lib/bclib.pl";

# special dir for dudmail
$maildir="/home/barrycarter/mail/dudmail";

# this is an actual 419 bait account I created
$acct = "leonard.zepowitz";
$url = "http://dudmail.com/for/$acct";

# which msgs do I already have for this account (note: using dudmails
# E?SMTPS? id is more reliable than using senders message-id)
my($cmd) = "egrep -i 'by dudmail.com .postfix. with E?SMTPS? id' $maildir/$acct";
my($out,$err,$res) = cache_command($cmd);
for $i (split(/\n/,$out)) {
  $i=~/id (.*?)$/ || warn("No ID: $i");
  $seen{$1} = 1;
}

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
  # unescape HTML
  $msg=~s/&lt;/</isg;
  $msg=~s/&gt;/>/isg;
  $msg=~s/&quot;/\"/isg;

  # find msg id
  $msg=~m%by dudmail.com \(postfix\) with E?SMTPS? id (.*?)\n%is || warn "NO DUDMAIL ID: $msg";
  my($dudid) = $1;
  debug("DUDID: $dudid");

  if ($seen{$dudid}) {
    debug("Already have: $dudid");
    next;
  }

  # TODO: check for duplicates, dont add msgs many times (but just testing now)
  append_file($msg, "$maildir/$acct");
}
