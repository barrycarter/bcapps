#!/bin/perl

# Send automated email to known scammers
# TODO: use scammer addresses as from addresses to

require "/usr/local/lib/bclib.pl";
use Data::Faker;

# domain to use (only while testing)
$domain = "graduate.org";

chdir("/home/barrycarter/BCGIT/419/");
my(%dude);
open(B,">/var/tmp/bchit.sh");

# scammer addresses
@addr = split(/\n/,`egrep -v '^#|^\$' confirmed2.txt|cut -d ' ' -f 2| fgrep -vf confirmed-bounces.txt`);

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
my($template) = read_file("TEMPLATES/13.txt");

$template=~s/\{(.*?)\}/$dude{$1}/isg;

# remove comments
$template=~s/#.*?\n//isg;

# special case for 13.txt (TODO: standardize this)
$dude{email_address} = "do_not_reply\@heathrow.com";

# loop
for $i (@addr) {
  # copy original template each time
  $mplate = $template;

  # to address changes each time
#  $mplate=~s/^To:.*?$/To: $i/m;

  # note: |sha1| is converted to recipient emails sha1
  # TODO: generalize concept of recipient-based templating
  $mplate=~s/\|sha1\|/sha1_hex($i)/iseg;
  $mplate=~s/\|email\|/$i/iseg;

  # write to file
  write_file($mplate,"/var/tmp/bchit-$i.txt");

  print B "sendmail -v -f$dude{email_address} -t < /var/tmp/bchit-$i.txt 1> /var/tmp/bchit-$i.out 2> /var/tmp/bchit-$i.err\n";
}

close(B);

# print data to file (w timestamp)
append_file(time()." ".join("|",%dude)."\n", "/var/tmp/bhsd.txt");

# really just shows it for last person
print $mplate;

print "\n\nTo actually send mail:\nsh /var/tmp/bchit.sh\n";

