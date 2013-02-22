#!/bin/perl

# Send automated email to known scammers
# TODO: use scammer addresses as from addresses to

require "/usr/local/lib/bclib.pl";
# $fromaddr= "vergetta.pervect\@dudmail.com";
# $fromaddr= "alfred.yankovic\@gmail.com";
# $fromaddr= "jennifer.perry\@usa.com";
# $fromaddr= "survey.master\@adexec.com";
# $fromaddr= "herman.bright\@accountant.com";
# $fromaddr= "anderson.posh\@lawyer.com";
# $fromaddr= "sarah.hill\@geologist.com";
# $fromaddr= "julia.wilson\@artlover.com";
$fromaddr= "barr.jsmith4\@lawyer.com";

# TODO: this is just testing to see to what extent they reply
@addr = split(/\n/,`egrep -v '^#|^\$' /home/barrycarter/BCGIT/419/confirmed.txt| fgrep -vf /home/barrycarter/BCGIT/419/confirmed-bounces.txt`);

open(B,">/var/tmp/bchit.sh");

for $i (@addr) {
  
  my($msg) = << "MARK";
From: John Smith Attorney at Law <$fromaddr>
To: $i
Subject: Please call me at home

I am an attorney, but I do not want to handle this through my office,
given the amount involved.

Could you call me at my home phone +1-602-354-9152

Please do not contact me at my office email again, this is not
something I want to share with my partners.

Thank you, John Smith (Atty at Law, Lices. AZ)

MARK
;

  write_file($msg,"/var/tmp/bchit-$i.txt");

  print B "sendmail -v -f$fromaddr -t < /var/tmp/bchit-$i.txt 1> /var/tmp/bchit-$i.out 2> /var/tmp/bchit-$i.err\n";
}

close(B);

print "To actually send mail:\nsh /var/tmp/bchit.sh\n";


