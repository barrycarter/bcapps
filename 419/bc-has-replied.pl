#!/bin/perl

# determines which scammers have replied to "bait" addresses of form
# leonard.zeptowitz+(number)@gmail.com

# NOTE: some of these might be legit people who just happened to
# reply; only added to confirmed.txt after looking at body of email

require "/usr/local/lib/bclib.pl";

print "Please remove all bounces from scambaiter mailbox, hit return\n";
<STDIN>;

# look in bait box (must double escape "+")
$cmd = "egrep 'leonard.zeptowitz\\+[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\@gmail.com' /home/barrycarter/mail/leonard.zeptowitz";
@addrs = `$cmd`;

for $i (@addrs) {
  while ($i=~s/(leonard\.zeptowitz\+\d+\@gmail\.com)//) {$addr{$1}=1;}
}

$str = join("\n", sort keys %addr);

write_file($str, "/var/tmp/bc-has-replied.txt");

system("fgrep -f /var/tmp/bc-has-replied.txt 419/pinged.txt | cut -d ' ' -f 2 | sort | uniq");

# TODO: more

# TODO: above includes bounces, which is bad

