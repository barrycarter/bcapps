#!/bin/perl

# Send automated email to known scammers
# TODO: use scammer addresses as from addresses to

require "/usr/local/lib/bclib.pl";
# $fromaddr= "vergetta.pervect\@dudmail.com";
# $fromaddr= "alfred.yankovic\@gmail.com";
# $fromaddr= "jennifer.perry\@usa.com";
# $fromaddr= "survey.master\@adexec.com";
# $fromaddr= "herman.bright\@accountant.com";
$fromaddr= "anderson.posh\@lawyer.com";

# TODO: this is just testing to see to what extent they reply
@addr = split(/\n/,`egrep -v '^#|^\$' /home/barrycarter/BCGIT/419/confirmed.txt| fgrep -vf /home/barrycarter/BCGIT/419/confirmed-bounces.txt`);

open(B,">/var/tmp/bchit.sh");

for $i (@addr) {
  
  my($msg) = << "MARK";
From: Anderson Posh <$fromaddr>
To: $i
Subject: Just got back home!

My apologies for the delay in getting back to you.

I just got back home, and am completely flooded with emails.

Could you call me at (646)-504-6977

Thanks,

Anderson Posh, attorney at law

MARK
;

  write_file($msg,"/var/tmp/bchit-$i.txt");

  print B "sendmail -v -f$fromaddr -t < /var/tmp/bchit-$i.txt 1> /var/tmp/bchit-$i.out 2> /var/tmp/bchit-$i.err\n";
}

close(B);

print "To actually send mail:\nsh /var/tmp/bchit.sh\n";


