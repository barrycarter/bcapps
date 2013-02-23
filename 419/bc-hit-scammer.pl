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
# $fromaddr= "barr.jsmith4\@lawyer.com";
# $fromaddr= "judith.jones\@lobbyist.com";
$fromaddr= "john.smith.bar\@lawyer.com";

# TODO: this is just testing to see to what extent they reply
@addr = split(/\n/,`egrep -v '^#|^\$' /home/barrycarter/BCGIT/419/confirmed.txt| fgrep -vf /home/barrycarter/BCGIT/419/confirmed-bounces.txt`);

open(B,">/var/tmp/bchit.sh");

for $i (@addr) {
  
  my($msg) = << "MARK";
From: Good Fellow <$fromaddr>
To: $i
Subject: Get America number

I am fellow man like you.

Sometimes, people in America will not call me since number is foriegn.

Now I discover: http://www.koalacalling.com/1/291/global_call_forwarding.asp

which gives me number in America, so more Americans call me.

If you sign up, tell my code name 'john.smith.bar@lawyer.com' so I
get small bonus.

MARK
;

  write_file($msg,"/var/tmp/bchit-$i.txt");

  print B "sendmail -v -f$fromaddr -t < /var/tmp/bchit-$i.txt 1> /var/tmp/bchit-$i.out 2> /var/tmp/bchit-$i.err\n";
}

close(B);

print "To actually send mail:\nsh /var/tmp/bchit.sh\n";


