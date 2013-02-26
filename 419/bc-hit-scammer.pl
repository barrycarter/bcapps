#!/bin/perl

# Send automated email to known scammers
# TODO: use scammer addresses as from addresses to

require "/usr/local/lib/bclib.pl";
use Data::Faker;

chdir("/home/barrycarter/BCGIT/419/");

# determine to address (this is probably inefficient)
$addr = `sort -R confirmed.txt|head -1`;

# fake up some data
my(%dude);
my($faker) = Data::Faker->new();
for $i ($faker->methods()) {
  $dude{$i} = $faker->$i();
}

for $i (sort keys %dude) {debug("$i: $dude{$i}");}

# debug($faker->methods());
# debug($faker->hostname());
# debug(unfold(%{$faker}));

die "TESTING";

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
# $fromaddr= "john.smith.bar\@lawyer.com";
$fromaddr= "anthony.bruce\@lawyer.com";

# TODO: this is just testing to see to what extent they reply
@addr = split(/\n/,`egrep -v '^#|^\$' /home/barrycarter/BCGIT/419/confirmed.txt| fgrep -vf /home/barrycarter/BCGIT/419/confirmed-bounces.txt`);

open(B,">/var/tmp/bchit.sh");

for $i (@addr) {
  
  my($msg) = << "MARK";
From: Mr Anthony Bruce <$fromaddr>
To: $i
Subject: Why haven't you called me?

This is Anthony Bruce.

I have been waiting for your call regarding my money.

Why have you not called me?

Please call me about my money RIGHT NOW at (602)-354-9152.

Anthony Bruce

MARK
;

  write_file($msg,"/var/tmp/bchit-$i.txt");

  print B "sendmail -v -f$fromaddr -t < /var/tmp/bchit-$i.txt 1> /var/tmp/bchit-$i.out 2> /var/tmp/bchit-$i.err\n";
}

close(B);

print "To actually send mail:\nsh /var/tmp/bchit.sh\n";


