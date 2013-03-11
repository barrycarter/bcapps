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

  debug("HEAD: $head", "BODY: $body");

#  warn "TESTING"; next;

  # headers of interest
  @heads = ();
  $to = "";
  debug("OHEAD: $head, OBODY: $body");
  for $i ("Return-Path", "Delivered-To", "X-Originating-Email", "From", "To", "Subject", "Date") {
    $head=~s/^($i:.*?)$//m;
    my($header) = $1;
    debug("HEADER: $header");
    push(@heads, $header);
    if ($i eq "To") {$to = $header;}
  }

  # which tagged address was this sent to
  debug("TO: $to");
  unless ($to=~/leonard\.zeptowitz\+(\d+)\@gmail\.com/i) {
    warn("BAD TO ADDRESS: $to");
  }

  my($num) = $1;

#  debug("HEADS", @heads, "TO: $to");

#  debug("HEAD: $head, BODY: $body");
}

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
