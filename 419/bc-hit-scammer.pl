#!/bin/perl

# Send automated email to known scammers
# TODO: use scammer addresses as from addresses to

require "/usr/local/lib/bclib.pl";
$fromaddr= "robert.hallman\@dudmail.com";

# TODO: this is just testing to see to what extent they reply
@addr = split(/\n/,`egrep -v '^#|^\$' /home/barrycarter/BCGIT/419/confirmed.txt`);

open(B,">/var/tmp/bchit.sh");

for $i (@addr) {
  
  my($msg) = << "MARK";
From: Robert Hallman <$fromaddr>
To: $i
Subject: re: your contact information

I received your email, but was a little confused. Could you call me at
940-468-3927 in the United States to clarify?

Here's the contact information you requested:

Dr Robert Hallman
1527 Eastern St
Mineral Hills, TX 72411

Please call me to let me know what I need to do next, thanks!
MARK
;

  write_file($msg,"/var/tmp/bchit-$i.txt");

  print B "sendmail -v -f$fromaddr -t < /var/tmp/bchit-$i.txt 1> /var/tmp/bchit-$i.out 2> /var/tmp/bchit-$i.err\n";
}

close(B);

print "To actually send mail:\nsh /var/tmp/bchit.sh\n";


