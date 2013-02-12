#!/bin/perl

# Send automated email to known scammers
# TODO: use scammer addresses as from addresses to

require "/usr/local/lib/bclib.pl";
# $fromaddr= "vergetta.pervect\@dudmail.com";
$fromaddr= "alfred.yankovic\@gmail.com";

# TODO: this is just testing to see to what extent they reply
@addr = split(/\n/,`egrep -v '^#|^\$' /home/barrycarter/BCGIT/419/confirmed.txt`);

open(B,">/var/tmp/bchit.sh");

for $i (@addr) {
  
  my($msg) = << "MARK";
From: Alfred Yankovic <$fromaddr>
To: $i
Subject: OK, ready to go here

OK, I am ready to go on this end.

Call me at 213-814-0993 in Glendale, CA, when you're ready to get
moving on this too!

Oh, ask for "Uncle Al" if someone else answers, they know who I am.

Thanks, Al!

MARK
;

  write_file($msg,"/var/tmp/bchit-$i.txt");

  print B "sendmail -v -f$fromaddr -t < /var/tmp/bchit-$i.txt 1> /var/tmp/bchit-$i.out 2> /var/tmp/bchit-$i.err\n";
}

close(B);

print "To actually send mail:\nsh /var/tmp/bchit.sh\n";


