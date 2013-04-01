#!/bin/perl

# determines which scammers have replied to "bait" addresses of form
# leonard.zeptowitz+(number)@gmail.com

# message modifications:
# long lines consisting of no spaces (usually attachment lines) deleted
# TODO: IN SOME CASES, this means the "proof" email appears nearly empty

# NOTE: some of these might be legit people who just happened to
# reply; only added to confirmed.txt after looking at body of email

# TODO: add bounces + maybe even non-scammy replies?
# TODO: look for spf bounces + treat them as non-bounces

require "/usr/local/lib/bclib.pl";
dodie('chdir("/home/barrycarter/BCGIT")');

# since I occasionally wipe out stuff in /var/tmp, recreate subdir
if (system("mkdir -p /var/tmp/bchr")) {
  die "mkdir fails";
}

$disclaimer = "[This message has been modified: see
https://github.com/barrycarter/bcapps/blob/master/419/bc-has-replied.pl
for details]";

# load the list/hash of pinged addresses
# TODO: at some point, this will become slow
# TODO: should really stop hardcoding leonard.zeptowitz everywhere
for $i (split(/\n/,read_file("419/pinged.txt"))) {
  chomp($i);
  $i=~/^leonard\.zeptowitz\+(\d+)\@gmail\.com\s+(.*)$/ || warn("BAD LINE: $i");
  $addr{$1}=$2;
}

# for now, print results to confirmed2.txt
# TODO: make this confirmed.txt and tweak bc-hit-scammer.pl to compensate
open(B,">419/confirmed2.txt");

# leonard.zeptowitz.has.replied.FINAL: where the scamlike replies are ultimately stored
# leonard.zeptowitz.has.replied: temporary storage for scamlike replies (small mailboxes work better w Alpine, especially over sshfs)

# mailbox below = scammer has replied in scam-like way
open(A,"/mnt/sshfs/MAIL/leonard.zeptowitz.has.replied.FINAL");

while (($head,$body) = next_email_fh(\*A)) {
  unless ($head) {last;}

  # fixup for continuation lines (mainly for subject)
  $head=~s/\n\s+/ /isg;

  # headers of interest
  @heads = (); %heads = ();
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
    warn("BAD TO ADDRESS: $heads{to}");
  }

  debug("TO: $heads{to}");

  # note: scammers send multiple emails to same address, but only ONE
  # is written to file (the rest are overwritten)
  my($num) = $1;

  # adding sha1 to see results of TEMPLATES/12.txt
  my($sha) = sha1_hex($addr{$num});

  # to confirmed2.txt print the scammer email address and the pinger address
  print B "$num $addr{$num} $sha\n";

  # compress 3 or more newlines to 2
  $body=~s/\n{3,}/\n\n/isg;

  # write offending message to file (currently non-public)
  $head = join("\n", @heads);
  write_file("$head\n\n$disclaimer\n\n$body\n", "/var/tmp/bchr/$num");
  # strip attachment like lines
  # TODO: this strips HTML attachments which is bad
  # TODO: sending to /var/tmp/ for testing only
#  $outdir = "/var/tmp/bchr";
  $outdir = "419/PROOFS/";
  $cmd = "grep -v --perl-regexp '^[a-zA-Z0-9\/\+]{50,}\$' /var/tmp/bchr/$num 1> $outdir/$num.txt";
  system($cmd);
}

close(B);

# pointless but useful
system("sort -nu 419/confirmed2.txt -o 419/confirmed2.txt");

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
