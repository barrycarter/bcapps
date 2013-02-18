#!/bin/perl

# determines which scammers have replied to "bait" addresses of form
# leonard.zeptowitz+(number)@gmail.com

# NOTE: some of these might be legit people who just happened to
# reply; only added to confirmed.txt after looking at body of email

# have safe checked all entries through:
# 04 Feb 2013: DUB117-W10825E22AD687301F0D0AFCAC010@phx.gbl
# 09 Feb 2013: 1360421609.38704.YahooMailNeo@web161405.mail.bf1.yahoo.com
# 11 Feb 2013: Message-ID: <CAHX6mmMs6-q3_07DjVBbLf6Pzxgjj5zp=PuMgTwRf=tC_gNcmg@mail.gmail.com>
# 13 Feb 2013: Message-ID: <CAJs=Yy4BNzVHb2_j7a83rhgrY36zxhZAv7FoPep-bkJyvFKsHA@mail.gmail.com>


require "/usr/local/lib/bclib.pl";
dodie('chdir("/home/barrycarter/BCGIT")');

print STDERR "Please remove all bounces from scambaiter mailbox\nconfirm that all emails to plus addresses are truly scamlike,\nthen hit return\n";
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

