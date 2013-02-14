#!/bin/perl

# Send automated email to known scammers
# TODO: use scammer addresses as from addresses to

require "/usr/local/lib/bclib.pl";
# $fromaddr= "vergetta.pervect\@dudmail.com";
# $fromaddr= "alfred.yankovic\@gmail.com";
# $fromaddr= "jennifer.perry\@usa.com";
$fromaddr= "survey.master\@adexec.com";

# TODO: this is just testing to see to what extent they reply
@addr = split(/\n/,`egrep -v '^#|^\$' /home/barrycarter/BCGIT/419/confirmed.txt| fgrep -vf /home/barrycarter/BCGIT/419/confirmed-bounces.txt`);

open(B,">/var/tmp/bchit.sh");

for $i (@addr) {
  
  my($msg) = << "MARK";
From: Survey Master International <$fromaddr>
To: $i
Subject: Please complete 10 question survey for \$100

Our research company would like to pay you \$100 to complete this brief
10-question survey.  Please send your reply to
survey.master\@adexec.com to receive your \$100, thank you.

1. What is your opinion of US President Barack Obama?

2. What is your favorite city in the world?

3. What is your least favorite city in the world?

4. To how many countries have you travelled?

5. Do you believe in God?

6. What is your opinion of the US state of Texas?

7. Would you rather live in Los Angeles or Miami?

8. Do you consider 80 degrees to be hot or just warm?

9. Who are your three favorite composers?

10. Would you be interested in completing a longer survey for
additional compensation?

MARK
;

  write_file($msg,"/var/tmp/bchit-$i.txt");

  print B "sendmail -v -f$fromaddr -t < /var/tmp/bchit-$i.txt 1> /var/tmp/bchit-$i.out 2> /var/tmp/bchit-$i.err\n";
}

close(B);

print "To actually send mail:\nsh /var/tmp/bchit.sh\n";


