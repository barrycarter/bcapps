#!/bin/perl

# determines which scammers have replied to "bait" addresses of form
# leonard.zeptowitz+(number)@gmail.com

# NOTE: some of these might be legit people who just happened to
# reply; only added to confirmed.txt after looking at body of email

require "/usr/local/lib/bclib.pl";
dodie('chdir("/home/barrycarter/BCGIT")');

# TODO: look out for emails from mailer-daemon

# mailbox below = scammer has replied in scam-like way
open(A,"/home/barrycarter/mail/leonard.zeptowitz.has.replied");

while (($head,$body) = next_email_fh(\*A)) {
  unless ($head) {last;}

  # fixup for continuation lines
  $head=~s/\n\s+/ /isg;

#  debug("HEAD: $head", "BODY: $body");

#  warn "TESTING"; next;

  # headers of interest
  @heads = (); %heads = (); $to = "";
  for $i ("Return-Path", "Delivered-To", "X-Originating-Email", "From", "To", "Subject", "Date") {
    $head=~s/^($i):(.*?)$//m;
    my($key,$val) = ($1,$2);
    unless ($key) {next;}
    push(@heads, "$key:$val");
    $heads{lc($key)} = $val;
  }

  # the annoying IMAP message
  if ($heads{subject}=~/DON\'T DELETE THIS MESSAGE -- FOLDER INTERNAL DATA/i) {next;}

  # did i put a bounce in here by mistake?
  for $i ("return-path", "x-originating-email", "from") {
    if ($heads{$i}=~/mailer/i) {
      die("EMAIL APPEARS TO BE FROM MAILER DAEMON: $had");
    }

    # put these addresses on the 'toping' list
    $pingme{$heads{$i}} = 1;
  }

  # which tagged address was this sent to
  unless ($heads{to}=~/leonard\.zeptowitz\+(\d+)\@gmail\.com/i) {
    warn("BAD TO ADDRESS: $to");
  }

  # note: scammers send multiple emails to same address, but only ONE
  # is written to file (the rest are overwritten)
  my($num) = $1;

  # write offending message to file (currently non-public)
  $head = join("\n", @heads);
  write_file("$head\n\n$body\n", "/var/tmp/bchr/$num.txt");

}

# find true email addresses in pingme
for $i (sort keys %pingme) {
  if ($i=~/[<\[](.*?)[>\]]/) {
    $trueping{$1} = 1;
  } else {
    $trueping{trim($i)} = 1;
  }
}

# TODO: I could simply print these above?
for $i (sort keys %trueping) {print "$i\n";}

die "TESTING";

# look in bait-reply box (must double escape "+")
$cmd = "egrep 'leonard.zeptowitz\\+[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\@gmail.com' /home/barrycarter/mail/leonard.zeptowitz.has.replied";
@addrs = `$cmd`;

for $i (@addrs) {
  while ($i=~s/(leonard\.zeptowitz\+\d+\@gmail\.com)//) {$addr{$1}=1;}
}

$str = join("\n", sort keys %addr);

write_file($str, "/var/tmp/bc-has-replied.txt");

system("fgrep -f /var/tmp/bc-has-replied.txt 419/pinged.txt | cut -d ' ' -f 2 | sort | uniq");

# TODO: more
