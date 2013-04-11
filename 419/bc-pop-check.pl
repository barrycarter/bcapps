#!/bin/perl

# Run from cron, POP checks mailinator.com accounts as needed
require "/usr/local/lib/bclib.pl";

# I dont even really use this program anymore, but its a good test for mylock
mylock("bc-pop-check", "lock");

@accts = ("Lily.Swaniawski");

for $i (@accts) {
  # mailinator.com is public email, but requires at least 2 chars for pw
  system("popclient -s -3 -u $i -p xx pop.mailinator.com -o /home/barrycarter/mail/MAILINATOR");
}
