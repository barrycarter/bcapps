#!/bin/perl -0777

# because of my mail setup, having cron send email to root (or even to
# an alternate address using MAILTO) doesn't work well. Instead, I
# send email to this program and put
# 'CRONDARGS=-m/home/barrycarter/BCGIT/bc-crond.pl' at the end of
# /etc/sysconfig/crond and restarted cron. I tried '-m"cat >>
# /home/barrycarter/mail/CRON"' but this failed.
# Note that the target mailbox must be writeable by mail(?) user for
# this to work

require "/usr/local/lib/bclib.pl";
append_file(<STDIN>,"/home/barrycarter/mail/CRON");
