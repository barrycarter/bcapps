#!/bin/perl

# Pings potential scammers with traceable leonard.zeptowitz addresses

require "/usr/local/lib/bclib.pl";
$dir = "/home/barrycarter/BCGIT/419";
dodie('chdir($dir)');
# gmail catcher addr
$catch = "leonard.zeptowitz";
$now = time();

# TODO: in theory, if I run this frequently enough, timestamps could
# collide; this is unlikely, but perhaps "tail -1 pinged.txt" to be
# extra careful

# read entries from toping.txt (too much Unix below?)
@emails = `egrep -v '^#|^\$' toping.txt | sort | uniq | sed 's/ //g'`;

# read entries from already pinged
@pinged = `cut -d' ' -f 2 pinged.txt`;

# subtract pinged from emails
@res = minus(\@emails, \@pinged);

unless (@res) {
  die "There are no new addresses in toping.txt, edit pinged.txt or toping.txt";
}

# will add these to pinged.txt
open(A,">>pinged.txt");
# shell file to actually send emails
open(B,">/var/tmp/bcping.sh");

for $i (@res) {
  chomp($i);
  # use TOD for sending addr
  # TODO: bad?
  # <h>y2.1k!</h>
  $fromaddr = strftime("$catch+%y%m%d%H%M%S\@gmail.com", gmtime($now++));

  # note that subject/body are fixed (for now)
my($str) = << "MARK";
From: Leonard Zeptowitz <$fromaddr>
To: $i
Subject: About the email you sent me?

Could you please give me details about the email you sent me? Thank you!

MARK
;

  # write string to /var/tmp/bcping-from.txt
  write_file($str,"/var/tmp/bcping-$fromaddr.txt");
  # write to shell file
  print B "sendmail -v -f$fromaddr -t < /var/tmp/bcping-$fromaddr.txt 1> /var/tmp/bcping-$fromaddr.out 2> /var/tmp/bcping-$fromaddr.err\n";

  # write to pinged.txt
  print A "$fromaddr $i\n";
}

close(A);

print "To actually send mail:\nsh /var/tmp/bcping.sh\n";



