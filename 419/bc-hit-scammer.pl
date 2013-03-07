#!/bin/perl

# Send automated email to known scammers
# TODO: use scammer addresses as from addresses to

require "/usr/local/lib/bclib.pl";
use Data::Faker;

# domain to use (only while testing)
$domain = "mailinator.com";

chdir("/home/barrycarter/BCGIT/419/");
my(%dude);
open(B,">/var/tmp/bchit.sh");

# scammer addresses
@addr = split(/\n/,`egrep -v '^#|^\$' confirmed.txt| fgrep -vf confirmed-bounces.txt`);

# fake up some data
my($faker) = Data::Faker->new();
for $i ($faker->methods()) {
  $dude{$i} = $faker->$i();
}

# I dislike the "extension" thing
$dude{phone_number}=~s/\s*x.*$//isg;

# data faker emails not believable in this use case
# TODO: dont hardcode domain (just for testing now)
$dude{email_address} = "$dude{first_name}.$dude{last_name}\@$domain";

# TODO: randomize
my($template) = read_file("/var/tmp/3a.txt");

$template=~s/\{(.*?)\}/$dude{$1}/isg;

# special case for re-send only
$dude{email_address} = "lily.swaniawski\@gmx.com";

# loop
for $i (@addr) {
  # to address changes each time
  $template=~s/^To:.*?$/To: $i/m;

  # write to file
  write_file($template,"/var/tmp/bchit-$i.txt");

  print B "sendmail -v -f$dude{email_address} -t < /var/tmp/bchit-$i.txt 1> /var/tmp/bchit-$i.out 2> /var/tmp/bchit-$i.err\n";
}

close(B);

# print data to file (w timestamp)
append_file(time()." ".join("|",%dude)."\n", "/var/tmp/bhsd.txt");

print $template;

print "\n\nTo actually send mail:\nsh /var/tmp/bchit.sh\n";

