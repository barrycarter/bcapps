#!/bin/perl

# Send automated email to known scammers
# TODO: use scammer addresses as from addresses to

require "/usr/local/lib/bclib.pl";

# TODO: this is just testing to see to what extent they reply
@addr = split(/\n/,`egrep -v '^#|^\$' /home/barrycarter/BCGIT/419/confirmed.txt`);

for $i (@addr) {
  $rand = int(rand()*(1e+10-1e+9))+1e+9;
#  sendmail("adam.adamson\@dudmail.com", $i, "I have sent the money", "The MTCN they gave me is $rand. Please reply back that you get this money, thank you!");
  # recorded twilio number forwarding to free sex line
  sendmail("bob.bobson\@dudmail.com", $i, "Please call me now", "Sequel to your email, please call me at 802-275-4787 in the USA as soon as you can!");
}
