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
write_file(<STDIN>,"/tmp/test7.txt");
exit(0);

# the mail "cron -m" sends does not have the "from space" line nor a
# date line, so I add these

# NOTE: this date isnt exactly in the right format but close enough?
$date = `date`;
$date=~s/\s*$//isg;

$all = <STDIN>; chomp($all);

$str = << "MARK";
From daemon\@barrycarter.info $date
From: Daemon <daemon\@barrycarter.info>
Date: $date

$all

MARK
;

debug("STR: $str");
